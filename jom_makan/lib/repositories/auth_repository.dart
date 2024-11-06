import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:jom_makan/constants/collections.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:jom_makan/models/operatingHours.dart'; 




class AuthRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  // Get the current user
  auth.User? get currentUser => _firebaseAuth.currentUser;
  // auth.Restaurant? get currentRestaurant => _firebaseAuth.currentUser;
  String? get currentRestaurantId => _firebaseAuth.currentUser?.uid;
  

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
          status: "active",
          commentByAdmin: "",
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

  // Sign up restaurant with email and password, and save restaurant info in Firestore
  Future<auth.User?> signUpRestaurantWithEmail({
    required String email,
    required String password,
    required String name,
    required GeoPoint location,
    required List<String> cuisineType,
    required List<String> menu,
    required Map<String, OperatingHours> operatingHours,
    required String intro,
    required String image,
    required List<String> tags,
  }) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final auth.User? user = userCredential.user;

      if (user != null) {
        Restaurant newRestaurant = Restaurant(
          id: user.uid,
          name: name,
          location: location,
          cuisineType: cuisineType,
          menu: menu,
          operatingHours: operatingHours,
          intro: intro,
          image: image,
          tags: tags,
          status: 'pending',
          commentByAdmin: '',
          email: email,
          // password: password,
        );

        await restaurantCollection.doc(user.uid).set(newRestaurant.toFirestore());
        // return user.uid;
      }

      return user;
    } catch (e) {
      print('Error signing up restaurant with email: $e');
      return null;
    }
  }

  // Sign in restaurant with email and password
  Future<auth.User?> signInRestaurantWithEmail(String email, String password) async {
    try {
      final auth.UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in restaurant with email: $e');
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

  String? getRestaurantId() {
   return _firebaseAuth.currentUser?.uid;
}
}