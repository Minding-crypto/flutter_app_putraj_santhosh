import 'dart:async';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/postDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class MySharedPreferencess {
  static const String _keyData = 'myData';
  static const String _keyExpiration = 'expirationTime';

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
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
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

class Like with ChangeNotifier {
  final String postId;
  bool _isLiked = false;
  late StreamSubscription<bool> _subscription;

  Like(this.postId) {
    _listenForChanges();
  }

  bool get isLiked => _isLiked;

  void _listenForChanges() {
    _subscription = _getIsLiked(postId).listen((isLiked) {
      _isLiked = isLiked;
      notifyListeners();
    });
  }

  void toggleLike() async {
    _isLiked = !_isLiked;
    notifyListeners();

    try {
      final liked = await _likePost(postId);
      _isLiked = liked;
      notifyListeners();
    } catch (e) {
      // Revert back if there is an error
      _isLiked = !_isLiked;
      notifyListeners();
    }
  }

  Future<bool> _likePost(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final currentUser = FirebaseAuth.instance.currentUser;
    bool isLiked = false;

    if (currentUser != null) {
      final userId = currentUser.uid;
      final likeDoc = await postRef.collection('likes').doc(userId).get();
      if (likeDoc.exists) {
        // User already liked the post, so unlike it
        await likeDoc.reference.delete();
      } else {
        // User hasn't liked the post yet, so like it
        await postRef.collection('likes').doc(userId).set({'liked_by': userId});
        isLiked = true;
      }
    }

    return isLiked;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Stream<bool> _getIsLiked(String postId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      return FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .snapshots()
          .map((snapshot) => snapshot.exists);
    }
    return const Stream<bool>.empty();
  }
}

User? loggedinUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  List<Map<String, dynamic>> _images = [];
  ScrollController _scrollController = ScrollController();
  Map<String, bool?> _likedPosts = {};
  bool _isLoading = true;
  static bool _imagesLoadedThisSession = false;
  Map<String, bool> _ratedPosts = {};
  late SharedPreferences prefs;

  // Initialize SharedPreferences instance
  final MySharedPreferencess _sharedPrefs = MySharedPreferencess();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    initSharedPreferences(); // Call initSharedPreferences here
    // _loadImages();
    _loadImageMetadata();
  }

  // Initialize SharedPreferences instance
  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance(); // Await the instance
  }

  bool retrieveRatedState(String postId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      return prefs.getBool('$postId-$userId') ?? false;
    }
    return false;
  }

  // Method to save rated state to SharedPreferences
  // Method to save rated state to SharedPreferences
  Future<void> saveRatedState(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      await prefs.setBool('$postId-$userId', true);
      setState(() {
        _ratedPosts[postId] = true;
      });
    }
  }
  // Method to retrieve rated state from SharedPreferences
// Method to retrieve rated state from SharedPreferences

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _forceRefreshImages();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {}
  }

  Future<void> _loadImages() async {
    if (_HomeScreenState._imagesLoadedThisSession) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final cachedData = await _sharedPrefs.getData();

      if (cachedData != null) {
        setState(() {
          _images = cachedData;
          _isLoading = false;
          _HomeScreenState._imagesLoadedThisSession = true;
        });
      } else {
        List<Map<String, dynamic>> files = [];

        final ListResult result = await storage.ref().list();
        final List<Reference> allFiles = result.items;

        await Future.forEach<Reference>(allFiles, (file) async {
          final String fileUrl = await file.getDownloadURL();
          final FullMetadata fileMeta = await file.getMetadata();
          final comments = await _loadComments(file.fullPath);
          final likes = await _getLikesCount(file.fullPath);
          final userRating = await _getUserRating(file.fullPath);
          final String uploadedByUid =
              fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';

          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('usernames')
              .doc(uploadedByUid)
              .get();
          final userData = userDoc.data() as Map<String, dynamic>?;
          final String username =
              userData?['username'] as String? ?? 'Anonymous';

          _likedPosts.putIfAbsent(file.fullPath, () => false);
          final overallRating = await _getAverageRating(file.fullPath);

          files.add({
            "url": fileUrl,
            "path": file.fullPath,
            "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
            "uploaded_by_uid": uploadedByUid,
            "username": username,
            "description":
                fileMeta.customMetadata?['description'] ?? 'No description',
            "comments": comments,
            "likes": likes,
            "isLiked": _likedPosts[file.fullPath] ?? false,
            "userRating": userRating,
            "overallRating": overallRating,
          });
        });

        await _sharedPrefs.saveData(files);

        if (mounted) {
          setState(() {
            _images = files;
            _isLoading = false;
            _HomeScreenState._imagesLoadedThisSession = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Map<String, dynamic> _convertToJson(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
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

  void _forceRefreshforthenewimages() async {
  // Delete the current cache
  await _sharedPrefs.deleteCache();

  // Reset the session flag to force a reload
  _HomeScreenState._imagesLoadedThisSession = false;

  // Show a loading indicator
  setState(() {
    _isLoading = true;
  });

  try {
    // Clear existing images
    _images.clear();

    // Fetch metadata directly from Firebase, bypassing any cache
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final FullMetadata fileMeta = await file.getMetadata();
      final String uploadedByUid = fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';

      // Fetch the username from the 'usernames' collection
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(uploadedByUid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final String username = userData?['username'] as String? ?? 'Anonymous';

      files.add({
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "uploaded_by_uid": uploadedByUid,
        "username": username,
        "description": fileMeta.customMetadata?['description'] ?? 'No description',
        "isLoaded": false,
      });
    });

    // Save fetched metadata to cache
    await _sharedPrefs.saveData(files);

    if (mounted) {
      setState(() {
        _images = files;
        _isLoading = false;
        _HomeScreenState._imagesLoadedThisSession = true;
      });
    }
  } catch (e) {
    // Handle error (e.g., show error message)
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// New method to save data with expiration

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<Map<String, dynamic>>> _loadComments(String postId) async {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments');
    final commentsSnapshot = await commentsRef.get();
    List<Map<String, dynamic>> comments = [];
    for (var doc in commentsSnapshot.docs) {
      final replies = await _loadReplies(postId, doc.id);
      comments.add({
        'id': doc.id,
        ...doc.data(),
        'replies': replies,
        'showReplyInput': false, // Initialize showReplyInput as false
        'showReplies': false, // Initialize showReplies as false
      });
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
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Future<int> _getLikesCount(String postId) async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .get();
    return likesSnapshot.docs.length;
  }

  Future<bool> _likePost(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final currentUser = _auth.currentUser;
    bool isLiked = false;

    if (currentUser != null) {
      final userId = currentUser.uid;
      final likeDoc = await postRef.collection('likes').doc(userId).get();
      if (likeDoc.exists) {
        // User already liked the post, so unlike it
        await likeDoc.reference.delete();
      } else {
        // User hasn't liked the post yet, so like it
        await postRef.collection('likes').doc(userId).set({'liked_by': userId});
        isLiked = true;
      }
    }

    return isLiked;
  }

  void addImage(Map<String, dynamic> newImage) {
    setState(() {
      _images.add(newImage);
    });
  }

  Future<bool> handleLikeButtonTap(bool isLiked, String imagePath) async {
    bool newIsLiked = await _likePost(imagePath);
    return newIsLiked;
  }

  void _forceRefreshImages() {
    _HomeScreenState._imagesLoadedThisSession = false;
    setState(() {
      _isLoading = true;
    });
    _loadImages();
  }

  Future<void> _saveUserRating(String postId, double rating) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      // Update the user's rating in Firestore under a subcollection with the user's ID
      await postRef.collection('ratings').doc(userId).set({'rating': rating});

      // Update rated status locally
      _ratedPosts[postId] = true;

      // Store rated status persistently with user ID
      // For example, you can use SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$postId-$userId', true);
    }
  }

  Future<double?> _getUserRating(String imagePath) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final ratingDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(imagePath)
          .collection('ratings')
          .doc(userId)
          .get();
      if (ratingDoc.exists) {
        return ratingDoc['rating'];
      }
    }
    return null; // Return null if no rating found
  }

  Stream<double> getAverageRatingStream(String postId) {
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
      int count = 0;

      for (var doc in snapshot.docs) {
        totalRating += doc['rating'];
        count++;
      }

      return totalRating / count;
    });
  }

  void _showRatingDialog(
    BuildContext context,
    Map<String, dynamic> image,
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
            snapshot.exists ? snapshot['rating'].toDouble() : 5.0;
        bool hasExistingRating = snapshot.exists;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: const Color.fromARGB(177, 0, 0, 0),
                  title: Center(
                    child: Text(
                      hasExistingRating
                          ? 'Your Rating: ${selectedRating.toStringAsFixed(1)}'
                          : 'Rate',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  content: Container(
                    height: 200,
                    width: 100,
                    child: WheelChooser.integer(
                      onValueChanged: (value) {
                        setState(() {
                          selectedRating = value.toDouble();
                        });
                      },
                      maxValue: 10,
                      minValue: 1,
                      step: 1,
                      initValue: selectedRating.toInt(),
                      listHeight: 200,
                      unSelectTextStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      selectTextStyle:
                          const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          image['userRating'] = selectedRating.toInt();
                        });
                        await _saveUserRating(image['path'], selectedRating);
                        Navigator.of(context).pop();
                        setStateCallback();
                      },
                      child: Text(hasExistingRating
                          ? 'Update Rating'
                          : 'Submit Rating'),
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

  Future<void> _loadImageMetadata() async {
    if (_HomeScreenState._imagesLoadedThisSession) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final cachedData = await _sharedPrefs.getData();

      if (cachedData != null) {
        setState(() {
          _images = cachedData;
          _isLoading = false;
          _HomeScreenState._imagesLoadedThisSession = true;
        });
      } else {
        List<Map<String, dynamic>> files = [];

        final ListResult result = await storage.ref().list();
        final List<Reference> allFiles = result.items;

        await Future.forEach<Reference>(allFiles, (file) async {
          final FullMetadata fileMeta = await file.getMetadata();
          final String uploadedByUid =
              fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown';

          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('usernames')
              .doc(uploadedByUid)
              .get();
          final userData = userDoc.data() as Map<String, dynamic>?;
          final String username =
              userData?['username'] as String? ?? 'Anonymous';

          files.add({
            "path": file.fullPath,
            "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
            "uploaded_by_uid": uploadedByUid,
            "username": username,
            "description":
                fileMeta.customMetadata?['description'] ?? 'No description',
            "isLoaded": false,
          });
        });

        await _sharedPrefs.saveData(files);

        if (mounted) {
          setState(() {
            _images = files;
            _isLoading = false;
            _HomeScreenState._imagesLoadedThisSession = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadImageData(int index) async {
    if (_images[index]['isLoaded'] == true) return;

    final file = _images[index];
    final String fileUrl = await storage.ref(file['path']).getDownloadURL();
    final comments = await _loadComments(file['path']);
    final likes = await _getLikesCount(file['path']);
    final userRating = await _getUserRating(file['path']);
    final overallRating = await _getAverageRating(file['path']);

    setState(() {
      _images[index] = {
        ..._images[index],
        "url": fileUrl,
        "comments": comments,
        "likes": likes,
        "isLiked": _likedPosts[file['path']] ?? false,
        "userRating": userRating,
        "overallRating": overallRating,
        "isLoaded": true, // Make sure this line is present
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts', style: TextStyle(color: Colors.white)),
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
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.twistingDots(
              leftDotColor: const Color.fromARGB(255, 123, 123, 255),
              rightDotColor: const Color(0xFFEA3799),
              size: 70,
            ))
          : MasonryGridView.count(
              controller: _scrollController,
              crossAxisCount: 2,
              itemCount: _images.length,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 10.0,
              itemBuilder: (context, index) {
                final image = _images[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostDetails(image: image),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Skeletonizer(
                                enabled: !(image['isLoaded'] ?? false),
                                child: Image.network(
                                  image['url'] ??
                                      'https://via.placeholder.com/250',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      _loadImageData(index);
                                      return child;
                                    }
                                    return const SizedBox(
                                      width: double.infinity,
                                      height: 250,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Column(
                                children: [
                                  RatingButton(
                                    imagePath: image['path'],
                                    onPressed: () {
                                      _showRatingDialog(
                                        context,
                                        image,
                                        () {
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class RatingButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const RatingButton(
      {super.key, required this.imagePath, required this.onPressed});

  @override
  RatingButtonState createState() => RatingButtonState();
}

class RatingButtonState extends State<RatingButton> {
  bool _isRated = false;

  @override
  void initState() {
    super.initState();
    _checkIfRated();
  }

  Future<void> _checkIfRated() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final ratingDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.imagePath)
          .collection('ratings')
          .doc(userId)
          .get();
      setState(() {
        _isRated = ratingDoc.exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: _isRated ? Colors.white : Colors.black,
        backgroundColor: _isRated
            ? const Color.fromARGB(104, 129, 32, 255)
            : const Color.fromARGB(113, 255, 255, 255),
      ),
      onPressed: widget.onPressed,
      child: Text(_isRated ? 'Rated' : 'Rate'),
    );
  }
}
