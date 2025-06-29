
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/postDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/scancards/creditspage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static const String _keyData = 'profileData';
  static const String _keyExpiration = 'profileExpirationTime';

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
        final expiration = DateTime.fromMillisecondsSinceEpoch(expirationTimestamp);
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
        return MapEntry(key, value.map((v) {
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
        return MapEntry(key, value.map((v) {
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
  Future<void> clearCache() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyData);
  await prefs.remove(_keyExpiration);
}
}


User? loggedinUser;

class personalprofile extends StatefulWidget {
  static const routeName = '/personalprofile';

  const personalprofile({super.key});

  @override
  _personalprofileState createState() => _personalprofileState();
}

class _personalprofileState extends State<personalprofile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  List<Map<String, dynamic>> _images = [];
  String _username = '';
  bool _loading = true;
    Map<String, bool> _ratedPosts = {};
  bool isPrefsInitialized = false;
  int _userCredits = 0;

  static bool _profileLoadedThisSession = false;

  // Initialize SharedPreferences instance
  final MySharedPreferences _sharedPrefs = MySharedPreferences();

 @override
void initState() {
  super.initState();
  getCurrentUser();
  _getUserData();
  _loadImages();
  _fetchUserCredits(); 
   //_setUserCredits(100);// Call the new function here
}

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  _forceRefreshProfile(); // Always refresh when dependencies change or when revisiting the page
}


//below i _setusercredits is trying out only







Future<void> _fetchUserCredits() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData != null) {
      setState(() {
        _userCredits = userData['credits'] ?? 0; // Assuming 'credits' field exists in the user document
      });
    }
  }
}

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _username = userData['username'];
        });
      }
    }
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

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _loadImages() async {
    if (_personalprofileState._profileLoadedThisSession) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Check if cached data exists
      final cachedData = await _sharedPrefs.getData();

      if (cachedData != null) {
        // Use cached data
        setState(() {
          _images = cachedData;
          _loading = false;
          _personalprofileState._profileLoadedThisSession = true;
        });
      } else {
        // Fetch data from Firebase
        List<Map<String, dynamic>> files = [];

        final ListResult result = await storage.ref().list();
        final List<Reference> allFiles = result.items;

        await Future.forEach<Reference>(allFiles, (file) async {
          final FullMetadata fileMeta = await file.getMetadata();
          final String uploadedByUid =
              fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';

          if (uploadedByUid == loggedInUser?.uid) {
            final String fileUrl = await file.getDownloadURL();
            final comments = await _loadComments(file.fullPath);
            final likes = await _getLikesCount(file.fullPath);
            final postId = file.fullPath;
            final overallRating = await _getAverageRating(postId);

            files.add({
              "url": fileUrl,
              "path": file.fullPath,
              "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
              "uploaded_by_uid": uploadedByUid,
              "description": fileMeta.customMetadata?['description'] ?? 'No description',
              "comments": comments,
              "likes": likes,
              "overallRating": overallRating
            });
          }
        });

        // Save fetched data to cache
        await _sharedPrefs.saveData(files);

        if (mounted) {
          setState(() {
            _images = files;
            _loading = false;
            _personalprofileState._profileLoadedThisSession = true;
          });
        }
      }
    } catch (e) {
      // Handle error (e.g., show error message, try to fetch from server)
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _forceRefreshProfile() {
    _personalprofileState._profileLoadedThisSession = false;
    _loadImages();
  }




Future<void> _forceRefreshforthenewimages() async {
  // Delete the current cache
  await _sharedPrefs.deleteCache();

  // Reset the session flag to force a reload
  _personalprofileState._profileLoadedThisSession = false;

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
          fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';

      if (uploadedByUid == loggedInUser?.uid) {
        final String fileUrl = await file.getDownloadURL();
        final comments = await _loadComments(file.fullPath);
        final likes = await _getLikesCount(file.fullPath);

        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usernames')
            .doc(uploadedByUid)
            .get();
        final userData =
            userDoc.data() as Map<String, dynamic>?; // Cast to a nullable Map
        final String username = userData?['username'] as String? ?? 'Anonymous';

        files.add({
          "url": fileUrl,
          "path": file.fullPath,
          "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
          "uploaded_by_uid": uploadedByUid,
          "username": username,
          "description": fileMeta.customMetadata?['description'] ?? 'No description',
          "comments": comments,
          "likes": likes,
          "isLiked": false, // Reset like status
        });
      }
    });

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
    print("Error refreshing images: $e");
  }
}




  Future<List<Map<String, dynamic>>> _loadComments(String postId) async {
    final commentsRef =
        FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments');
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

  Future<List<Map<String, dynamic>>> _loadReplies(String postId, String commentId) async {
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
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

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





Future<void> _delete(String ref) async {
  try {
    await storage.ref(ref).delete();
    await _sharedPrefs.deleteCache(); // Clear cache after deleting
  } catch (e) {
    print("Error deleting post: $e");
    // You might want to show an error message to the user here
  } finally {
    // Always refresh, even if there was an error
    if (mounted) {
      setState(() {
        _loading = true; // Show loading indicator while refreshing
      });
      await _forceRefreshforthenewimages(); // Call the refresh function
    }
  }
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






 Future<void> _saveUserRating(String postId, double rating) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      await postRef.collection('ratings').doc(userId).set({'rating': rating});
      _ratedPosts['$postId-$userId'] = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$postId-$userId', true);
      setState(() {}); // Force the state update
    }
  }


 void _showRatingDialog(
  BuildContext context,
  Map<String, dynamic> image,
  bool isRated,
  VoidCallback setStateCallback,
) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final userId = currentUser.uid;

    FirebaseFirestore.instance
        .collection('posts')
        .doc(image['path'])
        .collection('ratings')
        .doc(userId)
        .get()
        .then((snapshot) {
      double selectedRating =
          snapshot.exists ? snapshot['rating'].toDouble() : 0;

      ScrollController scrollController = ScrollController(
        initialScrollOffset: (selectedRating - 1) * 50,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  selectedRating > 0
                      ? 'Your Rating: ${selectedRating.toStringAsFixed(1)}'
                      : 'Rate Image',
                ),
                content: Container(
                  height: 200,
                  width: 100,
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int i) {
                      int rating = i + 1;
                      return ListTile(
                        title: Text('$rating'),
                        onTap: () {
                          setState(() {
                            selectedRating = rating.toDouble();
                          });
                        },
                        selected: selectedRating == rating.toDouble(),
                        selectedTileColor: Colors.blue.withOpacity(0.2),
                      );
                    },
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      await _saveUserRating(image['path'], selectedRating);
                      Navigator.of(context).pop();
                      setStateCallback();
                    },
                    child: Text(isRated ? 'Update Rating' : 'Submit Rating'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('User', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.pushNamed(context, 'settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _forceRefreshforthenewimages,
          ),
        ],
      ),

      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 // SizedBox(width: 10), // Add some spacing between username and credits
  
                Text(
                  '@$_username',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Posts: ${_images.length}',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
               Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BuyCreditsPage()),
    );
  },
  child: Text(
    '$_userCredits credits', // Display the user's credits
    style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 0, 0, 0)),
  ),
),

                /*  Text(
      '($_userCredits credits)', // Display the user's credits
      style: TextStyle(fontSize: 20, color: Colors.white),
    ),*/
              ],
            ),
            
            const SizedBox(height: 40),
            _loading
                ? Center(child:  LoadingAnimationWidget.twistingDots(
          leftDotColor: const Color.fromARGB(255, 123, 123, 255),
          rightDotColor: const Color(0xFFEA3799),
          size: 70,
        ),)
                : Expanded(
                    child: _images.isEmpty
                        ? const Center(
                            child: Text(
                              'No posts',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2.0,
                              mainAxisSpacing: 2.0,
                              childAspectRatio: 0.5,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> image = _images[index];
                              return GestureDetector(
                                onTap: () {
                                  if (image['url'] != '') {
                                    _postDetails(image);
                                  }
                                },
                                child: GridTile(
                                  header: Align(
                                    alignment: Alignment.topRight,
                                    child: PopupMenuButton(
  icon: const Icon(Icons.more_vert, color: Color.fromARGB(255, 108, 0, 0)),
  itemBuilder: (context) => [
    PopupMenuItem(
      child: ListTile(
        leading: const Icon(Icons.delete, color: Color.fromARGB(255, 108, 0, 0)),
        title: const Text('Delete'),
        onTap: () {
          // Close the PopupMenu
          Navigator.of(context).pop();
          
          // Show the delete confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Post"),
                content: const Text("Are you sure you want to delete this post?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("Delete"),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      await _delete(image['path']);
                      // The refresh is now handled within _delete(),
                      // so we don't need to do anything else here
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  ],
),
                                      
                                  
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      image['url'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  footer: GridTileBar(
                                    backgroundColor: Colors.black45,
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                         StreamBuilder<double>(
                          stream: _getOverallRatingStream(image['path']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final overallRating =
                                  snapshot.data?.toStringAsFixed(1) ??
                                      'No ratings yet';
                              return Text(
                                'Rating: $overallRating',
                                style: const TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),

                                     
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}