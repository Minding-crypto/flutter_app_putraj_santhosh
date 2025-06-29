import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/postDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';

class MySharedPreferencesa {
  static const String _keyData = 'rankingData';
  static const String _keyExpiration = 'rankingExpirationTime';

  Future<void> saveData(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = data.map((map) {
      final jsonSafeMap = _convertToJson(map);
      return jsonEncode(jsonSafeMap);
    }).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyData, jsonString);

    // Set expiration to 1 hour from now (adjust as needed)
    final expirationTime = DateTime.now().add(const Duration(hours: 1));
    await prefs.setInt(_keyExpiration, expirationTime.millisecondsSinceEpoch);
  }

  Future<List<Map<String, dynamic>>?> getData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expirationTimestamp = prefs.getInt(_keyExpiration);
      if (expirationTimestamp != null) {
        final expiration =
            DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
        if (expiration.isAfter(DateTime.now())) {
          final cachedData = prefs.getString(_keyData);
          if (cachedData != null) {
            final List<dynamic> jsonList = jsonDecode(cachedData);
            return jsonList.map((jsonString) {
              final dynamic decodedData = jsonDecode(jsonString);
              if (decodedData is Map) {
                return _convertFromJson(decodedData.cast<String, dynamic>());
              }
              return <String, dynamic>{};
            }).toList();
          }
        }
      }
    } catch (e) {
      // Clear corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyData);
      await prefs.remove(_keyExpiration);
    }
    return null; // Data has expired, doesn't exist, or there was an error
  }

  Map<String, dynamic> _convertToJson(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      } else if (value is List) {
        return MapEntry(
            key,
            value.map((v) {
              if (v is Map) {
                return _convertToJson(v.cast<String, dynamic>());
              }
              return v;
            }).toList());
      } else if (value is Map) {
        return MapEntry(key, _convertToJson(value.cast<String, dynamic>()));
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _convertFromJson(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is String && value.contains('T')) {
        try {
          return MapEntry(key, DateTime.parse(value));
        } catch (_) {
          return MapEntry(key, value);
        }
      } else if (value is List) {
        return MapEntry(
            key,
            value.map((v) {
              if (v is Map) {
                return _convertFromJson(v.cast<String, dynamic>());
              }
              return v;
            }).toList());
      } else if (value is Map) {
        return MapEntry(key, _convertFromJson(value.cast<String, dynamic>()));
      }
      return MapEntry(key, value);
    });
  }

  Future<void> deleteCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyData);
    await prefs.remove(_keyExpiration);
  }
}

class TopPostsPage extends StatefulWidget {
  static const routeName = '/personalprofile';

  const TopPostsPage({super.key});

  @override
  TopPostsPageState createState() => TopPostsPageState();
}

class TopPostsPageState extends State<TopPostsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  List<Map<String, dynamic>> _images = [];
  bool _loading = true;
  bool _isLoading = true;
  bool isPrefsInitialized = false;

  // Initialize SharedPreferences instance
  final MySharedPreferencesa _sharedPrefs = MySharedPreferencesa();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _loadImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _forceRefreshProfile(); // Always refresh when dependencies change or when revisiting the page
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
    }
  }
void _forceRefreshforthenewimages() async {
  // Delete the current cache
  await _sharedPrefs.deleteCache();

  // Reset the session flag to force a reload

  // Show a loading indicator
  setState(() {
    _loading = true;
  });

  try {
    // Clear existing images
    _images.clear();

    // Fetch data directly from Firebase, bypassing any cache
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final FullMetadata fileMeta = await file.getMetadata();
      final String uploadedByUid =
          fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown'; // Fetch the 'uploaded_by_uid' field

      final String fileUrl = await file.getDownloadURL();
      final comments = await _loadComments(file.fullPath);
      final likes = await _getLikesCount(file.fullPath);
      final overallRating = await _getAverageRating(file.fullPath);

      if (overallRating >= 7.0) {
        files.add({
          "url": fileUrl,
          "path": file.fullPath,
          "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
          "uploaded_by_uid": uploadedByUid,
          "description": fileMeta.customMetadata?['description'] ?? 'No description',
          "comments": comments,
          "likes": likes,
          "overallRating": overallRating,
        });
      }
    });

    // Sort files based on overallRating in descending order
    files.sort((a, b) => b['overallRating'].compareTo(a['overallRating']));

    // Save fetched data to cache
    await _sharedPrefs.saveData(files);

    if (mounted) {
      setState(() {
        _images = files;
        _isLoading = false;
      });
    }

    // Update the UI with the new data
    if (mounted) {
      setState(() {
        _images = files;
        _loading = false;
      });
    }

    // Save the new data to cache for future use
    await _sharedPrefs.saveData(files);
  } catch (e) {
    // Handle error (e.g., show error message)
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }
}

FirebaseStorage storage = FirebaseStorage.instance;

Future<void> _loadImages() async {
  try {
    // Check if cached data exists
    final cachedData = await _sharedPrefs.getData();

    if (cachedData != null) {
      // Use cached data
      setState(() {
        _images = cachedData.where((file) => file['overallRating'] >= 7.0).toList();
        _loading = false;
        _isLoading = false;
      });
    } else {
      // Fetch data from Firebase
      await _fetchImagesFromFirebase();
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _loading = false;
        _isLoading = false;
      });
    }
  }
}

Future<void> _fetchImagesFromFirebase() async {
  setState(() {
    _loading = true;
    _isLoading = true;
  });

  List<Map<String, dynamic>> files = [];

  final ListResult result = await storage.ref().list();
  final List<Reference> allFiles = result.items;

  await Future.forEach<Reference>(allFiles, (file) async {
    final FullMetadata fileMeta = await file.getMetadata();
    final String uploadedByUid = fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';
    final String fileUrl = await file.getDownloadURL();
    final comments = await _loadComments(file.fullPath);
    final likes = await _getLikesCount(file.fullPath);
    final overallRating = await _getAverageRating(file.fullPath); // Ensure to fetch the correct average rating

    if (overallRating >= 7.0) {
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "uploaded_by_uid": uploadedByUid,
        "description": fileMeta.customMetadata?['description'] ?? 'No description',
        "comments": comments,
        "likes": likes,
        "overallRating": overallRating,
      });
    }
  });

  // Sort files based on overallRating in descending order
  files.sort(_sortByRating);

  // Save fetched data to cache
  await _sharedPrefs.saveData(files);

  if (mounted) {
    setState(() {
      _images = files;
      _loading = false;
      _isLoading = false;
    });
  }
}

int _sortByRating(Map<String, dynamic> a, Map<String, dynamic> b) {
  final double aRating = a['overallRating'] ?? 0.0;
  final double bRating = b['overallRating'] ?? 0.0;

  // Sort in descending order
  return bRating.compareTo(aRating);
}


  void _forceRefreshProfile() {
    _loadImages();
  }

  Future<List<Map<String, dynamic>>> _loadComments(String postId) async {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');
    final commentsSnapshot = await commentsRef.get();
    List<Map<String, dynamic>> comments = [];
    for (var doc in commentsSnapshot.docs) {
      final commentedBy = doc['commentedBy'];
      if (commentedBy != null) {
        final replies = await _loadReplies(postId, doc.id);
        final commentedByUsername = await _getUserName(commentedBy);
        comments.add({
          'id': doc.id,
          'commentedBy': commentedByUsername,
          'comment': doc['comment'],
          'replies': replies,
        });
      }
    }
    return comments;
  }

  Future<List<Map<String, dynamic>>> _loadReplies(
      String postId, String commentId) async {
    final repliesRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');
    final repliesSnapshot = await repliesRef.get();
    return repliesSnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'repliedBy': doc['repliedBy'],
              'reply': doc['reply'],
            })
        .toList();
  }

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['username'];
      } else {
        return 'Unknown';
      }
    } catch (error) {
      return 'Unknown';
    }
  }

  Future<int> _getLikesCount(String postId) async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .get();
    return likesSnapshot.size;
  }







  Map<String, ValueNotifier<bool>> _postLikes = {};

  @override
  void dispose() {
    _postLikes.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  void _postDetails(Map<String, dynamic> image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetails(image: image),
      ),
    );
  }







 Stream<double> _getOverallRatingStream(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return 0.0;
      }
      double totalRating = 0;
      for (var doc in snapshot.docs) {
        totalRating += doc['rating'];
      }
      return totalRating / snapshot.docs.length;
    });
  }











  Future<double> _getAverageRating(String postId) async {
    final ratingSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('ratings')
        .get();

    if (ratingSnapshot.docs.isEmpty) {
      return 0.0;
    }

    double totalRating = 0;
    int count = 0;

    for (var doc in ratingSnapshot.docs) {
      totalRating += doc['rating'];
      count++;
    }

    return totalRating / count;
  }

 












  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Posts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
         automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _forceRefreshforthenewimages,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: _images.isEmpty &&
                !_loading &&
                !_isLoading // Check if _images is empty and both _loading and _isLoading are false
            ? const Center(
                child: Text(
                  'No Posts With Rating More Than 7.0',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : _loading || _isLoading
                ? Center(
                    child: LoadingAnimationWidget.twistingDots(
                      leftDotColor: const Color.fromARGB(255, 123, 123, 255),
                      rightDotColor: const Color(0xFFEA3799),
                      size: 70,
                    ),
                  )
                : ListView.builder(
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> image = _images[index];
                      return GestureDetector(
                        onTap: () {
                          if (image['url'] != '') {
                            _postDetails(image);
                          }
                        },
                        child: Card(
                          color: Colors.black,
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      image['url'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 300,
                                    ),
                                  ),
                                  Padding(
  padding: const EdgeInsets.all(8.0),
  child: Container(
  
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),   color: const Color.fromARGB(138, 0, 0, 0),),
    padding: const EdgeInsets.all(8.0), // Add some padding inside the container if needed
    child: StreamBuilder<double>(
      stream: _getOverallRatingStream(image['path']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Loading...',
            style: TextStyle(color: Colors.white), // Set text color to white for contrast
          );
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: Colors.white), // Set text color to white for contrast
          );
        } else {
          final overallRating =
              snapshot.data?.toStringAsFixed(1) ?? 'No ratings yet';
          return Text(
            'Rating: $overallRating',
            style: const TextStyle(color: Colors.white), // Set text color to white for contrast
          );
        }
      },
    ),
  ),
),

                                ],
                              ),
                              
                              // Add your like button and other widgets here
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
