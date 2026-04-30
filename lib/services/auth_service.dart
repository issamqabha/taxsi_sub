import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<(UserModel?, String?)> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('[SIGNUP] Creating user with email=$email, displayName=$displayName');
      
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('[SIGNUP] User created: uid=${userCredential.user!.uid}');

      // Create user document in Firestore
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      print('[SIGNUP] Writing to Firestore: ${userModel.toMap()}');
      
      await _firestore.collection('users').doc(userCredential.user?.uid).set(
            userModel.toMap(),
          );

      print('[SIGNUP] Firestore write successful');

      // THEN update display name in Firebase Auth
      await userCredential.user?.updateDisplayName(displayName);
      
      // Refresh the user to ensure displayName is synced
      await userCredential.user?.reload();

      print('[SIGNUP] Auth profile updated and reloaded. Final displayName=${userCredential.user?.displayName}');

      return (userModel, null);
    } on FirebaseAuthException catch (e) {
      print('[SIGNUP] FirebaseAuthException: ${e.message}');
      return (null, e.message ?? 'Sign up failed');
    } catch (e) {
      print('[SIGNUP] Error: $e');
      return (null, 'An error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<(UserModel?, String?)> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Refresh user to get latest displayName
      await userCredential.user?.reload();

      // Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user?.uid).get();

      if (userDoc.exists) {
        final userModel = UserModel.fromMap(userDoc.data()!);
        return (userModel, null);
      }

      return (null, 'User data not found');
    } on FirebaseAuthException catch (e) {
      return (null, e.message ?? 'Sign in failed');
    } catch (e) {
      return (null, 'An error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!);
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user displayName
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
        'displayName': displayName,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final uid = _auth.currentUser?.uid;
      await _auth.currentUser?.delete();
      if (uid != null) {
        await _firestore.collection('users').doc(uid).delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
