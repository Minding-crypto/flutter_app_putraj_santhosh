import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/postDetails.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? loggedinUser; 

class fakepage extends StatefulWidget {
  const fakepage({super.key});

  @override
  fakepageState createState() => fakepageState();
}

class fakepageState extends State<fakepage> {
  final _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  List<Map<String, dynamic>> _images = [];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _loadImages();
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
        maxWidth: 1920,
      );

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final String userEmail = currentUser.email ?? 'Unknown';
        final String userUid = currentUser.uid;
        try {
          // Upload image
          await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(
              customMetadata: {
                'uploaded_by_uid': userUid,
                'uploaded_by_email': userEmail,
                'description': 'Some description...',
              },
            ),
          );

          // Add post to Firestore
          await FirebaseFirestore.instance.collection('posts').add({
            'url': await storage.ref(fileName).getDownloadURL(),
            'uploaded_by_uid': userUid,
            'uploaded_by_email': userEmail,
            'description': 'Some description...',
          });

          // Reload images
          _loadImages();
        } on FirebaseException catch (error) {
          if (kDebugMode) {
            print(error);
          }
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

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('uploaded_by_uid', isEqualTo: currentUser.uid)
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
    }

    if (files.isEmpty) {
      // If no posts, show message
      files.add({
        "url": "",
        "path": "",
        "uploaded_by": "",
        "description": "No posts uploaded by user",
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

  Stream<int> _getLikes(String path) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(path)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }





  Future<void> _likePost(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userId = currentUser.uid;
      await postRef.collection('likes').doc(userId).set({'liked_by': userId});
      _loadImages();
    }
  }

  void _postDetails(Map<String, dynamic> image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetails(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('faker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _upload('camera'),
                  icon: const Icon(Icons.camera),
                  label: const Text('camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _upload('gallery'),
                  icon: const Icon(Icons.library_add),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> image = _images[index];
                    return Column(
                      children: [
                        if (index % 2 != 0) const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            if (image['url'] != '') {
                              _postDetails(image);
                            }
                          },
                          child: Container(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  // if (index % 2 != 0) SizedBox(height: 10),

                                  if (image['url'] != '')
                                    Container(
                                      height: 235,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(
                                                20)), // Change this value to adjust the height of the post image
                                        child: AspectRatio(
                                          aspectRatio: 16 /
                                              9, // Change the aspect ratio as per your requirement
                                          child: Image.network(
                                            image['url'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Transform.translate(
                                    offset: const Offset(0.0, 3.0),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          if (image['url'] != '')
                                            StreamBuilder<int>(
                                              stream: _getLikes(image['path']),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<int> snapshot) {
                                                if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                }
                                                switch (
                                                    snapshot.connectionState) {
                                                  case ConnectionState.waiting:
                                                    return const CircularProgressIndicator();
                                                  default:
                                                    return Row(
                                                      children: <Widget>[
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.thumb_up),
                                                          onPressed: () async {
                                                            await _likePost(
                                                                image['path']);
                                                            if (mounted) {
                                                              setState(() {
                                                                image['likes'] =
                                                                    snapshot.data ??
                                                                        0;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                            'Likes: ${snapshot.data ?? 0}'),
                                                      ],
                                                    );
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                 
                                 
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 