import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/postDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

User? loggedinUser;

class UserProfile extends StatefulWidget {
  static const routeName = '/userProfile';
  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final _auth = FirebaseAuth.instance;
  late User? loggedInUser;
  List<Map<String, dynamic>> _images = [];
  String _username = '';
  bool _loading = true;
  final Map<String, bool> _ratedPosts = {};
  bool isPrefsInitialized = false;

  // Initialize SharedPreferences instance

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _getUserData();
      await _loadImages(widget.userId);
    });
  }

  Future<void> _getUserData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('usernames')
        .doc(widget.userId)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    if (userData != null) {
      setState(() {
        _username = userData['username'];
      });
    }

    final QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uploaded_by_uid', isEqualTo: widget.userId)
        .get();
    for (var postDoc in postsSnapshot.docs) {
// Count the number of documents in the 'likes' subcollection
    }

    setState(() {});
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {}
  }

  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _loadImages(String userId) async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final FullMetadata fileMeta = await file.getMetadata();
      final String uploadedByUid =
          fileMeta.customMetadata?['uploaded_by_uid'] ??
              'Unknown'; // Fetch the 'uploaded_by_uid' field

      if (uploadedByUid == userId) {
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
          "description":
              fileMeta.customMetadata?['description'] ?? 'No description',
          "comments": comments,
          "likes": likes,
          "overallRating": overallRating
        });
      }
    });

    if (mounted) {
      setState(() {
        _images = files;
        _loading = false;
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
    int likesCount = 0;
    likesSnapshot.docs.forEach((doc) {
      likesCount++;
    });
    return likesCount;
  }

  final Map<String, ValueNotifier<bool>> _postLikes = {};

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

  void _showReportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Report User'),
        content: Text('You will be redirected to a Google Form to submit your report.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Continue'),
            onPressed: () {
              _submitReport();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _submitReport() async {
  final Uri formUrl = Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSeKD1VSR6cDCsHUa6lIj2x_o8t9kkxUlFiN8ID3YGPF9l-SOQ/viewform?usp=sf_link');
  
  if (await canLaunchUrl(formUrl)) {
    await launchUrl(formUrl, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open the report form')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.report),
            onPressed: () => _showReportDialog(context),
            color: Colors.white,
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
                Text(
                  '@$_username',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
            const SizedBox(height: 50),
            _loading
                ? Center(
                    child: LoadingAnimationWidget.twistingDots(
                      leftDotColor: const Color.fromARGB(255, 123, 123, 255),
                      rightDotColor: const Color(0xFFEA3799),
                      size: 70,
                    ),
                  )
                : Expanded(
                    child: _images.isEmpty
                        ? const Center(
                            child: Text(
                              'No posts',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        StreamBuilder<double>(
                                          stream: _getOverallRatingStream(
                                              image['path']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Text('Loading...');
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              final overallRating = snapshot
                                                      .data
                                                      ?.toStringAsFixed(1) ??
                                                  'No ratings yet';
                                              return Text(
                                                'Rating: $overallRating',
                                                style: const TextStyle(
                                                    color: Colors.white),
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
