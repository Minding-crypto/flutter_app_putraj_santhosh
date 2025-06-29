import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

 // static const routeName = '/settings';

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Future<void> _deleteAccount() async {
  final user = _auth.currentUser;
  if (user == null) return;

  try {
    // Delete user data from Firestore
    final userId = user.uid;
    await _firestore.collection('users').doc(userId).delete();

    // Delete user comments and replies
    final posts = await _firestore.collection('posts').get();
    for (var post in posts.docs) {
      final comments = await post.reference.collection('comments').get();
      for (var comment in comments.docs) {
        if (comment['commentedBy'] == userId) {
          await comment.reference.delete();
        } else {
          final replies = await comment.reference.collection('replies').get();
          for (var reply in replies.docs) {
            if (reply['repliedBy'] == userId) {
              await reply.reference.delete();
            }
          }
        }
      }
    }

    // Delete user images from Firestore and Storage
    final storageRef = FirebaseStorage.instance.ref();
    final images = await storageRef.listAll();
    for (var imageRef in images.items) {
      final metadata = await imageRef.getMetadata();
      if (metadata.customMetadata?['uploaded_by_uid'] == userId) {
        await imageRef.delete();
      }
    }

    // Delete user ratings
    // Assuming you have a collection for ratings
    final ratings = await _firestore.collection('ratings').where('ratedBy', isEqualTo: userId).get();
    for (var rating in ratings.docs) {
      await rating.reference.delete();
    }

    // Delete user account
    await user.delete();

    // Navigate back to welcome screen
    Navigator.pushNamedAndRemoveUntil(context, 'welcome_screen', (route) => false);
  } catch (error) {
    // Handle error here
    print("Error deleting account: $error");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Account"),
                  content: const Text("Are you sure you want to delete your account?"),
                  actions: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Delete"),
                      onPressed: () {
                        _deleteAccount();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Delete Account'),
        ),
      ),
    );
  }
}
 