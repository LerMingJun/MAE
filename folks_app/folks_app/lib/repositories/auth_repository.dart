import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:folks_app/constants/collections.dart';
import 'package:folks_app/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get the current user
  auth.User? get currentUser => _firebaseAuth.currentUser;
  

  // Sign up with email and password and save user info in Firestore
  Future<auth.User?> signUpWithEmail(String email, String password, String fullName, String username) async {
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
          impoints: 0,
          introduction: "",
          signinMethod: "Email",
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

  // Sign in with Google
  Future<auth.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
      return null;  
      }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        final auth.User? user = userCredential.user;

        // Check if the user is new or already exists in Firestore
        if (user != null) {
          final DocumentReference userDocRef = userCollection.doc(user.uid);
          final DocumentSnapshot userDoc = await userDocRef.get();

          if (!userDoc.exists) {

            User newUser = User(
              userID: user.uid,
              fullName: user.displayName ?? 'Google Full Name',
              username: user.displayName ?? 'Google Full Name',
              email: user.email ?? "Google Email",
              profileImage: user.photoURL ?? "userPlaceholder", 
              impoints: 0,
              introduction: "",
              signinMethod: "Google",
              createdAt: Timestamp.now(),
            );
            // Create a new document for the user
            await userDocRef.set(newUser.toJson());
          }
        }
        return user;
    
    } catch (e) {
      print('Error signing in with Google: $e');
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