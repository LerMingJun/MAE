import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jom_makan/constants/collections.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jom_makan/models/post.dart';
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

      // Create a new document in the top-level posts collection
      docRef = _firestore.collection('posts').doc();

      await docRef.set({
        'postID': docRef.id,
        'postImage': downloadUrl,
        'userID': userID,
        'title': title,
        'description': description,
        'tags': tags,
        'likes': [],
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error adding post: $e');
    }
  }

  Future<void> editPost(String postID, XFile? image, String title,
      String description, List<String> tags) async {
    try {
      Map<String, dynamic> updatedData = {
        'title': title,
        'description': description,
        'tags': tags,
      };

      if (image != null) {
        String fileName =
            'posts/post_${DateTime.now().millisecondsSinceEpoch}.png';
        Reference storageRef = _storage.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(File(image.path));
        TaskSnapshot taskSnapshot = await uploadTask;

        // Get download URL
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        updatedData['postImage'] = downloadUrl;
      }

      // Update document in the top-level posts collection
      await _firestore.collection('posts').doc(postID).update(updatedData);
    } catch (e) {
      throw Exception('Error updating post: $e');
    }
  }

  Future<List<Post>> fetchAllPosts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('posts').get();

      // Process each post document
      List<Post> posts = await Future.wait(snapshot.docs.map((doc) async {
        Post post = Post.fromFirestore(doc);
        // Check if userId is non-empty before fetching user document
        if (post.userID.isNotEmpty) {
          DocumentSnapshot userDoc =
              await userCollection.doc(post.userID).get();
          if (userDoc.exists) {
            post.user = User.fromFirestore(userDoc);
          } else {
            // Optionally handle missing user data
            print('User document does not exist for userId: ${post.userID}');
            post.user = null; // or set a default User object if needed
          }
        } else {
          print('userId is empty or null for post: ${post.postId}');
          post.user = null; // Handle missing user ID case
        }

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
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .where('userID', isEqualTo: userID)
          .get();

      DocumentSnapshot userDoc = await userCollection.doc(userID).get();
      User user = User.fromFirestore(userDoc);

      List<Post> posts = snapshot.docs.map((doc) {
        Post post = Post.fromFirestore(doc);
        post.user = user;
        return post;
      }).toList();

      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      throw e;
    }
  }

  Future<Post?> fetchPostByPostID(String postID) async {
    try {
      DocumentSnapshot postDoc =
          await _firestore.collection('posts').doc(postID).get();

      if (postDoc.exists) {
        Post post = Post.fromFirestore(postDoc);

        DocumentSnapshot userDoc = await userCollection.doc(post.userID).get();
        post.user = User.fromFirestore(userDoc);

        return post;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching posts: $e');
      throw e;
    }
  }

  Future<void> likePost(String postID, String userID) async {
    try {
      DocumentReference postRef = _firestore.collection('posts').doc(postID);
      await postRef.update({
        'likes': FieldValue.arrayUnion([userID]),
      });
    } catch (e) {
      print('Error liking post: $e');
      throw e;
    }
  }

  Future<void> unlikePost(String postID, String userID) async {
    try {
      DocumentReference postRef = _firestore.collection('posts').doc(postID);
      await postRef.update({
        'likes': FieldValue.arrayRemove([userID]),
      });
    } catch (e) {
      print('Error unliking post: $e');
      throw e;
    }
  }

  Future<void> deletePost(String postID) async {
    try {
      await _firestore.collection('posts').doc(postID).delete();
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }
}
