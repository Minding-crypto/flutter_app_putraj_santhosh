import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/user_profile.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

User? loggedinUser;

class PostDetails extends StatefulWidget {
  final Map<String, dynamic> image;
  final String? username;
  final String? loggedinUserId;

  const PostDetails({
    Key? key,
    required this.image,
    this.username,
    this.loggedinUserId,
  }) : super(key: key);

  @override
  PostDetailsState createState() => PostDetailsState();
}

class PostDetailsState extends State<PostDetails> {
  final TextEditingController _commentController = TextEditingController();
  late SharedPreferences prefs;
  Map<String, bool> _ratedPosts = {};
  bool isPrefsInitialized = false;

  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _images = [];
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    initSharedPreferences();
    initializePrefs();
    _loadImages();
    _checkInitialRatingState();
  }

  void _checkInitialRatingState() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _ratedPosts['${widget.image['path']}-$userId'] =
            prefs.getBool('${widget.image['path']}-$userId') ?? false;
      });
    }
  }

  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance(); // Await the instance
  }

  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isPrefsInitialized = true; // Set the flag to true after initialization
    });
  }

  bool retrieveRatedState(String postId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      return _ratedPosts['$postId-$userId'] ?? false;
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
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
    }
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          final String userUid = currentUser.uid;
          final String userEmail = currentUser.email ?? 'Unknown';
          // Fetch the username from the 'users' collection
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userUid)
              .get();
          final userData =
              userDoc.data() as Map<String, dynamic>?; // Cast to a nullable Map
          final String username =
              userData?['username'] as String? ?? 'Anonymous';

          // Upload image
          final uploadTask = storage.ref(fileName).putFile(
                imageFile,
                SettableMetadata(
                  customMetadata: {
                    'uploaded_by_uid': userUid,
                    'uploaded_by_email': userEmail,
                    'description': 'Some description...',
                  },
                ),
              );

          // Get the download URL of the uploaded image
          final TaskSnapshot taskSnapshot = await uploadTask;
          final String fileUrl = await taskSnapshot.ref.getDownloadURL();

          // Add post to Firestore
          final postRef =
              await FirebaseFirestore.instance.collection('posts').add({
            'url': fileUrl,
            'uploaded_by_uid': userUid,
            'uploaded_by_email': userEmail,
            'description': 'Some description...',
          });

          // Store the username separately
          await FirebaseFirestore.instance
              .collection('usernames')
              .doc(userUid)
              .set({
            'username': username,
          });

          _loadImages();
        }
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  Future<void> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      final comments = await _loadComments(file.fullPath);
      final likes = await _getLikesCount(file.fullPath);
      final userRating = await _getUserRating(file.fullPath);

      final postId = file.fullPath; // Ensure you have a valid postId here
      final overallRating = await _getAverageRating(postId);

      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "uploaded_by_uid":
            fileMeta.customMetadata?['uploaded_by_uid'] ?? 'Unknown',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description',
        "comments": comments,
        "likes": likes,
        "userRating": userRating,
        "overallRating": overallRating
      });
    });

    if (mounted) {
      setState(() {
        _images = files;
      });
    }
  }

  Stream<List<Map<String, dynamic>>> _loadComments(String path) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(path)
        .collection('comments')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final replies = _loadReplies(path, doc.id);
        return {
          'id': doc.id,
          'comment': doc['comment'],
          'commentedBy': doc['commentedBy'],
          'timestamp': doc['timestamp'],
          'replies': replies,
          'showReplyInput': false, // Initialize showReplyInput as false
          'showReplies': false, // Initialize showReplies as false
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> _loadReplies(
      String path, String commentId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(path)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'reply': doc['reply'],
          'repliedBy': doc['repliedBy'],
          'timestamp': doc['timestamp'],
        };
      }).toList();
    });
  }

  Future<int> _getLikesCount(String path) async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(path)
        .collection('likes')
        .get();
    return likesSnapshot.docs.length;
  }

  Future<void> _deleteReply(String postId, String commentId, String replyId,
      BuildContext context) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);
    try {
      await commentRef.collection('replies').doc(replyId).delete();
      final updatedComments = await _loadComments(postId);
      final index = _images.indexWhere((image) => image['path'] == postId);
      setState(() {
        _images[index]['comments'] = updatedComments;
      });
    } catch (error) {
    }
  }

  Future<void> _deleteComment(
      String postId, String commentId, BuildContext context) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);
    final commentData = (await commentRef.get()).data();
    final commentedBy = commentData?['commentedBy'];
    final currentUser = _auth.currentUser;
    if (currentUser != null && commentedBy == currentUser.uid) {
      await commentRef.delete();
      final index = _images.indexWhere((image) => image['path'] == postId);
      final List<Map<String, dynamic>> updatedComments =
          List.from(_images[index]['comments']);
      updatedComments.removeWhere((comment) => comment['id'] == commentId);
      setState(() {
        _images[index]['comments'] = updatedComments;
      });
    }
  }

  Future<void> _replyToComment(
      String postId, String commentId, String reply) async {
    if (postId.isNotEmpty) {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final commentRef = postRef.collection('comments').doc(commentId);
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        try {
          await commentRef.collection('replies').add({
            'reply': reply,
            'repliedBy': userId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          final updatedComments = await _loadComments(postId);
          final index = _images.indexWhere((image) => image['path'] == postId);
          setState(() {
            _images[index]['comments'] = updatedComments;
            _replyController.clear();
          });
        } catch (error) {
        }
      }
    } else {
    }
  }

  Future<void> _addComment(String postId, String comment) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      try {
        await postRef.collection('comments').add({
          'comment': comment,
          'commentedBy': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (error) {
      }
    }
  }




  /* @override
  void dispose() {
    _postLikes.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }*/

  Future<void> _loadImagesForUser(String username) async {
    List<Map<String, dynamic>> files = [];

    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('uploaded_by_username', isEqualTo: username)
        .get();

    for (var doc in snapshot.docs) {
      final String fileUrl = doc['url'];
      final String filePath = doc.id;
      final comments = await _loadComments(filePath);
      final likes = await _getLikesCount(filePath);
      files.add({
        "url": fileUrl,
        "path": filePath,
        "uploaded_by": doc['uploaded_by_email'] ?? 'Nobody',
        "description": doc['description'] ?? 'No description',
        "comments": comments,
        "likes": likes,
      });
    }

    if (files.isEmpty) {
      // If no posts, show message
      files.add({
        "url": "",
        "path": "",
        "uploaded_by": "",
        "description": "No posts uploaded by this user",
        "comments": [],
        "likes": 0,
      });
    }

    if (mounted) {
      setState(() {
        _images = files;
      });
    }
  }


  void _postDetails(Map<String, dynamic> image) async {
    final String userId = image['uploaded_by_uid'];
    final String username = image['username'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfile(userId: userId),
      ),
    );
  }

  Stream<int> _getCommentsCountStream(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Color getRandomColor() {
    Random random = Random();
    List<Color> colors = [
      const Color.fromARGB(255, 170, 201, 223), // Your original color
      const Color.fromARGB(255, 206, 169, 203), // Another color
      const Color.fromRGBO(218, 213, 208, 1), // Another color
    ];
    return colors[random.nextInt(colors.length)];
  }

// Define a map to store the showReplies state for each comment
  Map<String, bool> showRepliesMap = {};

// Initialize showRepliesMap with false for each comment
  void _initializeShowRepliesMap(List<Map<String, dynamic>> comments) {
    comments.forEach((comment) {
      showRepliesMap[comment['id']] = false;
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
    return null;
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
                    child: Text(hasExistingRating ? 'Update Rating' : 'Submit Rating'),
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


  @override
  Widget build(BuildContext context) {
    // Print the entire image data map
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      backgroundColor:
          const Color.fromRGBO(0, 0, 0, 1), // Set background color to black
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                      /*  StreamBuilder<double>(
                          stream: _getOverallRatingStream(widget.image['path']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading...');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final overallRating =
                                  snapshot.data?.toStringAsFixed(1) ??
                                      'No ratings yet';
                              return Text(
                                'Rating: $overallRating',
                                style: TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),

                        // User Rating
                        StreamBuilder<double?>(
                          stream: _getUserRatingStream(widget.image['path']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Loading...');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final userRating =
                                  snapshot.data?.toStringAsFixed(1) ??
                                      'No rating';
                              return Text(
                                'Your Rating: $userRating',
                                style: TextStyle(color: Colors.white),
                              );
                            }
                          },
                        ),*/
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('usernames')
                                .doc(widget.image['uploaded_by_uid'])
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // While data is loading, show a loading indicator
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                // If there's an error, show an error message
                                return Text(
                                  'Error fetching username: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.white),
                                );
                              } else {
                                // If data is successfully loaded
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  final userData = snapshot.data!.data()
                                      as Map<String, dynamic>?;
                                  final String username =
                                      userData?['username'] ?? 'Anonymous';

                                  // Use the username in your app's UI
                                  return GestureDetector(
                                    onTap: () {
                                      _loadImagesForUser(
                                          username); // Load images for this username
                                      Navigator.pushNamed(
                                        context,
                                        UserProfile.routeName,
                                        arguments: {
                                          'userId':
                                              widget.image['uploaded_by_uid'],
                                          'username':
                                              username, // Pass the username as an argument
                                        },
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          height:
                                              500, // Set the height of the Container
                                          width:
                                              400, // Set the width of the Container
                                          child: Card(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                              ), // Add a border radius
                                            ),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                              ), // Match the border radius with the Card
                                              child: Image.network(
                                                widget.image['url'] ??
                                                    '', // Ensure that 'url' is not null
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '@$username',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // If the username document does not exist
                                  return const Text(
                                    'Uploaded by: Unknown',
                                    style: TextStyle(color: Colors.white),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                children: [
                                RatingButton(
                                  imagePath: widget.image['path'],
                                  onPressed: () {
                                    _showRatingDialog(
                                      context,
                                      widget.image,
                                      () {
                                        setState(() {});
                                      },
                                    );
                                  },
                                ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  StreamBuilder<double>(
                                    stream: _getOverallRatingStream(
                                        widget.image['path']),
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
                              StreamBuilder<int>(
                                stream: _getCommentsCountStream(
                                    widget.image['path']),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final commentsCount = snapshot.data!;
                                    return Row(
                                      children: [
                                        IconButton(
                                            icon: const Icon(
                                              Icons.mode_comment_outlined,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              size: 30,
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.black87,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              20)),
                                                ),
                                                builder: (context) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .unfocus(); // close keyboard
                                                      setState(() {
                                                        // close input section
                                                        widget.image['comments']
                                                            .forEach((comment) {
                                                          comment['showReplyInput'] =
                                                              false;
                                                        });
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom,
                                                      ),
                                                      child: StatefulBuilder(
                                                        builder: (BuildContext
                                                                context,
                                                            StateSetter
                                                                setState) {
                                                          return Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.6,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              20),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          StreamBuilder<
                                                                              List<Map<String, dynamic>>>(
                                                                            stream:
                                                                                _loadComments(widget.image['path']),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.hasData && snapshot.data != null) {
                                                                                final comments = snapshot.data!;
                                                                                return Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Comments (${commentsCount})',
                                                                                      style: const TextStyle(
                                                                                        color: Colors.white,
                                                                                        fontSize: 18,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(height: 10),
                                                                                    ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                                      itemCount: comments.length,
                                                                                      itemBuilder: (context, index) {
                                                                                        final comment = comments[index];
                                                                                        return Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            ListTile(
                                                                                              title: Text(
                                                                                                comment['comment'] ?? '',
                                                                                                style: const TextStyle(color: Colors.white), // Set text color to white
                                                                                              ),
                                                                                              subtitle: FutureBuilder<DocumentSnapshot>(
                                                                                                future: FirebaseFirestore.instance.collection('users').doc(comment['commentedBy']).get(),
                                                                                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                                                                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                                                                                    return const Text('Unknown', style: TextStyle(color: Colors.white)); // Set text color to white
                                                                                                  }

                                                                                                  final data = snapshot.data!.data();
                                                                                                  if (data != null) {
                                                                                                    final Map<String, dynamic> userData = data as Map<String, dynamic>;
                                                                                                    if (userData.containsKey('username')) {
                                                                                                      final String username = userData['username'] as String? ?? 'Anonymous';
                                                                                                      return GestureDetector(
                                                                                                        onTap: () {
                                                                                                          _loadImagesForUser(username); // Load images for this username
                                                                                                          Navigator.push(
                                                                                                            context,
                                                                                                            MaterialPageRoute(
                                                                                                              builder: (context) => UserProfile(userId: comment['commentedBy']), // Use 'commentedBy' instead of 'uploaded_by_uid'
                                                                                                            ),
                                                                                                          );
                                                                                                        },
                                                                                                        child: Text(
                                                                                                          '$username',
                                                                                                          style: const TextStyle(color: Colors.grey), // Set text color to white
                                                                                                        ),
                                                                                                      );
                                                                                                    }
                                                                                                  }
                                                                                                  return const Text(
                                                                                                    'Unknown',
                                                                                                    style: TextStyle(color: Colors.white),
                                                                                                  ); // Set text color to white
                                                                                                },
                                                                                              ),
                                                                                              trailing: Row(
                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                children: [
                                                                                                  IconButton(
                                                                                                    icon: const Icon(
                                                                                                      Icons.reply,
                                                                                                      color: Colors.white, // Set icon color to white
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      showDialog(
                                                                                                        context: context,
                                                                                                        builder: (BuildContext context) {
                                                                                                          return AlertDialog(
                                                                                                            title: const Text('Reply to Comment'),
                                                                                                            content: TextField(
                                                                                                              onChanged: (value) {
                                                                                                                setState(() {
                                                                                                                  _replyController.text = value;
                                                                                                                });
                                                                                                              },
                                                                                                              decoration: const InputDecoration(hintText: "Enter your reply here"),
                                                                                                            ),
                                                                                                            actions: [
                                                                                                              ElevatedButton(
                                                                                                                child: const Icon(Icons.send),
                                                                                                                onPressed: () {
                                                                                                                  _replyToComment(
                                                                                                                    widget.image['path'],
                                                                                                                    comment['id'],
                                                                                                                    _replyController.text,
                                                                                                                  );
                                                                                                                  Navigator.of(context).pop();
                                                                                                                },
                                                                                                              ),
                                                                                                            ],
                                                                                                          );
                                                                                                        },
                                                                                                      );
                                                                                                    },
                                                                                                  ),
                                                                                                  if (comment['commentedBy'] == loggedinUser?.uid)
                                                                                                    IconButton(
                                                                                                      icon: const Icon(Icons.delete, color: Colors.red),
                                                                                                      onPressed: () {
                                                                                                        _deleteComment(
                                                                                                          widget.image['path'],
                                                                                                          comment['id'],
                                                                                                          context,
                                                                                                        );
                                                                                                      },
                                                                                                    ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            if (showRepliesMap[comment['id']] ?? false)
                                                                                              StreamBuilder<List<Map<String, dynamic>>>(
                                                                                                stream: comment['replies'],
                                                                                                builder: (context, snapshot) {
                                                                                                  if (snapshot.hasData) {
                                                                                                    final replies = snapshot.data!;
                                                                                                    return ListView.builder(
                                                                                                      shrinkWrap: true,
                                                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                                                      itemCount: replies.length,
                                                                                                      itemBuilder: (context, index) {
                                                                                                        final reply = replies[index];
                                                                                                        return Padding(
                                                                                                          padding: const EdgeInsets.only(left: 35.0),
                                                                                                          child: ListTile(
                                                                                                            title: Text(
                                                                                                              reply['reply'],
                                                                                                              style: const TextStyle(color: Colors.white), // Set text color to white
                                                                                                            ),
                                                                                                            subtitle: FutureBuilder<DocumentSnapshot>(
                                                                                                              future: FirebaseFirestore.instance.collection('users').doc(reply['repliedBy']).get(),
                                                                                                              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                                                                                                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                                                                                                  return const Text('Unknown', style: TextStyle(color: Colors.white)); // Set text color to white
                                                                                                                }
                                                                                                                final data = snapshot.data!.data();
                                                                                                                if (data != null) {
                                                                                                                  final Map<String, dynamic> userData = data as Map<String, dynamic>;
                                                                                                                  if (userData.containsKey('username')) {
                                                                                                                    final String username = userData?['username'] as String? ?? 'Anonymous';
                                                                                                                    return GestureDetector(
                                                                                                                      onTap: () {
                                                                                                                        _loadImagesForUser(username); // Load images for this username
                                                                                                                        Navigator.push(
                                                                                                                          context,
                                                                                                                          MaterialPageRoute(
                                                                                                                            builder: (context) => UserProfile(userId: reply['repliedBy']), // Use 'commentedBy' instead of 'uploaded_by_uid'
                                                                                                                          ),
                                                                                                                        );
                                                                                                                      },
                                                                                                                      child: Text(
                                                                                                                        '$username',
                                                                                                                        style: const TextStyle(color: Colors.grey), // Set text color to white
                                                                                                                      ),
                                                                                                                    );
                                                                                                                  }
                                                                                                                }
                                                                                                                return const Text(
                                                                                                                  'Unknown',
                                                                                                                  style: TextStyle(color: Colors.white),
                                                                                                                ); // Set text color to white
                                                                                                              },
                                                                                                            ),
                                                                                                            trailing: reply['repliedBy'] == loggedinUser?.uid
                                                                                                                ? IconButton(
                                                                                                                    icon: const Icon(
                                                                                                                      Icons.close,
                                                                                                                      color: Color.fromARGB(255, 151, 151, 151),
                                                                                                                    ),
                                                                                                                    onPressed: () {
                                                                                                                      _deleteReply(
                                                                                                                        widget.image['path'],
                                                                                                                        comment['id'],
                                                                                                                        reply['id'],
                                                                                                                        context,
                                                                                                                      );
                                                                                                                    },
                                                                                                                  )
                                                                                                                : null,
                                                                                                          ),
                                                                                                        );
                                                                                                      },
                                                                                                    );
                                                                                                  } else {
                                                                                                    return const CircularProgressIndicator();
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 10),
                                                                                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                                                                                stream: comment['replies'],
                                                                                                builder: (context, snapshot) {
                                                                                                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                                                                                    return TextButton(
                                                                                                      onPressed: () {
                                                                                                        setState(() {
                                                                                                          // Toggle the showReplies
                                                                                                          showRepliesMap[comment['id']] = !(showRepliesMap[comment['id']] ?? false);
                                                                                                        });
                                                                                                      },
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: 25, // Adjust the width as needed
                                                                                                            height: 1,
                                                                                                            color: const Color.fromARGB(255, 156, 154, 154), // Adjust the color as needed
                                                                                                            margin: const EdgeInsets.only(right: 5), // Space between line and text
                                                                                                          ),
                                                                                                          Text(
                                                                                                            showRepliesMap[comment['id']] ?? false ? 'Hide Replies' : 'View Replies',
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    );
                                                                                                  } else {
                                                                                                    return const SizedBox.shrink();
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              } else if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                return const CircularProgressIndicator();
                                                                              } else {
                                                                                return const Text(
                                                                                  'No comments',
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ); // Set text color to white
                                                                              }
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                TextFormField(
                                                                  controller:
                                                                      _commentController,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    hintText:
                                                                        'Add a comment...',
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            left:
                                                                                10),
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Center(
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      if (_commentController
                                                                          .text
                                                                          .trim()
                                                                          .isNotEmpty) {
                                                                        await _addComment(
                                                                          widget
                                                                              .image['path'],
                                                                          _commentController
                                                                              .text,
                                                                        );
                                                                        _commentController
                                                                            .clear();
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                        'Post Comment'),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                        Text(
                                          'Comments: ${commentsCount}',
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255)),
                                        ), // Set text color to white
                                      ],
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class RatingButton extends StatefulWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const RatingButton({super.key, required this.imagePath, required this.onPressed});

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
