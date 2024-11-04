import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:jom_makan/constants/collections.dart';
import 'package:jom_makan/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get the current user
  auth.User? get currentUser => _firebaseAuth.currentUser;
  

  // Sign up with email and password and save user info in Firestore
  Future<auth.User?> signUpWithEmail(String email, String password, String fullName, String username, List<String> dietaryPreferences) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final auth.User? user = userCredential.user;

      if (user != null) {
        User newUser = User(
          userID: user.uid,
          fullName: fullName,
          username: username,
          email: email,
          profileImage: "userPlaceholder", 
          dietaryPreferences: dietaryPreferences,
          createdAt: Timestamp.now(),
        );

        await userCollection.doc(user.uid).set(newUser.toJson());
      }

      return user;
    } catch (e) {
      print('Error signing up with email: $e');
      return null;
    }
  }


  // Sign in with email and password
  Future<auth.User?> signInWithEmail(String email, String password) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in with email: $e');
      return null;
    }
  }


  // Sign out
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get currently signed-in user
  auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

}