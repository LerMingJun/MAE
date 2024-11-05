import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jom_makan/constants/collections.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/models/activity.dart';
import 'package:jom_makan/models/project.dart';
import 'package:jom_makan/models/post.dart';
import 'package:jom_makan/models/speech.dart';
import 'package:jom_makan/models/user.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addPost(String userID, XFile? image, String title,
      String description, List<String> tags) async {
    DocumentReference docRef;
    try {
      String? downloadUrl;

      if (image != null) {
        String fileName =
            'posts/$userID/post_${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = _storage.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get download URL
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Create a new document in the posts collection
      docRef =
          await userCollection.doc(userID).collection(postSubCollection).doc();

      await docRef.set({
        'postID': docRef.id,
        'postImage': downloadUrl,
        'userID': userID,
        'title': title,
        'description': description,
        'tags': tags, // Include tags
        'likes': [],
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error adding post: $e');
    }
  }

  Future<void> editPost(String postID, XFile? image, String title,
      String description, List<String> tags, String userID) async {
    try {
      Map<String, dynamic> updatedData = {
        'title': title,
        'description': description,
        'tags': tags, // Include tags
      };

      if (image != null) {
        String fileName =
            'posts/$userID/post_${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = _storage.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        updatedData['postImage'] = downloadUrl;
      }

      // Update document in the posts collection
      await userCollection
          .doc(userID)
          .collection(postSubCollection)
          .doc(postID)
          .update(updatedData);
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }

  Future<List<Post>> fetchAllPosts() async {
    try {
      // Query all posts subcollections across all users
      QuerySnapshot snapshot =
          await _firestore.collectionGroup(postSubCollection).get();

      // Process each post document
      List<Post> posts = await Future.wait(snapshot.docs.map((doc) async {
        // Fetch the parent user document to get the user information
        DocumentSnapshot userDoc = await doc.reference.parent.parent!.get();
        Post post = Post.fromFirestore(doc);
        post.user = User.fromFirestore(
            userDoc); // Use the User model to populate user details

        return post;
      }).toList());

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      throw e;
    }
  }

  Future<List<Post>> fetchAllPostsByUserID(String userID) async {
    try {
      // Fetch posts from the user's posts subcollection
      QuerySnapshot snapshot =
          await userCollection.doc(userID).collection(postSubCollection).get();

      DocumentSnapshot userDoc = await userCollection.doc(userID).get();

      // Convert the user document to a User object
      User user = User.fromFirestore(userDoc);

      // Map each post document to a Post object and assign the user
      List<Post> posts = snapshot.docs.map((doc) {
        Post post = Post.fromFirestore(doc);
        post.user = user; // Assign the user object to the post
        return post;
      }).toList();

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      throw e;
    }
  }

  Future<Post?> fetchPostByPostID(String userID, String postID) async {
    try {
      DocumentSnapshot postDoc = await userCollection
          .doc(userID)
          .collection(postSubCollection)
          .doc(postID)
          .get();

      if (postDoc.exists) {
        Post post = Post.fromFirestore(postDoc);

        // Fetch the user document
        DocumentSnapshot userDoc = await userCollection.doc(userID).get();
        post.user = User.fromFirestore(userDoc);

        return post;
      } else {
        return null; // No post found with the given postID
      }
    } catch (e) {
      print('Error fetching posts: $e');
      throw e;
    }
  }

  Future<void> likePost(String postID, String userID) async {
    try {
      // Use collectionGroup to find the post by postID across all posts subcollections
      QuerySnapshot postSnapshot = await _firestore
          .collectionGroup(postSubCollection)
          .where('postID', isEqualTo: postID)
          .get();

      // Check if the post exists
      if (postSnapshot.docs.isNotEmpty) {
        // There should be only one document with this postID, but we'll take the first one
        DocumentReference postRef = postSnapshot.docs.first.reference;

        // Update the likes array
        await postRef.update({
          'likes': FieldValue.arrayUnion([userID]),
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      print('Error liking post: $e');
      throw e;
    }
  }

  Future<void> unlikePost(String postID, String userID) async {
    try {
      // Use collectionGroup to find the post by postID across all posts subcollections
      QuerySnapshot postSnapshot = await _firestore
          .collectionGroup(postSubCollection)
          .where('postID', isEqualTo: postID)
          .get();

      // Check if the post exists
      if (postSnapshot.docs.isNotEmpty) {
        // There should be only one document with this postID, but we'll take the first one
        DocumentReference postRef = postSnapshot.docs.first.reference;

        // Update the likes array
        await postRef.update({
          'likes': FieldValue.arrayRemove([userID]),
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      print('Error liking post: $e');
      throw e;
    }
  }

  Future<void> deletePost(String userID, String postID) async {
    try {
      // Navigate to the user's posts subcollection and delete the post
      return await userCollection
          .doc(userID)
          .collection(postSubCollection)
          .doc(postID)
          .delete();
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }
}
