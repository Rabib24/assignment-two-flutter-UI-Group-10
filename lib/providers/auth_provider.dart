import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthManager with ChangeNotifier {  // Renamed from AuthProvider to AuthManager
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  AuthManager() {  // Constructor name updated
    _user = _auth.currentUser;
    _fetchUserData();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        final doc = await _firestore.collection('users').doc(_user!.uid).get();
        _userData = doc.data();
        notifyListeners();
      } on FirebaseException catch (e) {
        debugPrint("Firebase error fetching user data: ${e.code} - ${e.message}");
        // Don't throw error for permission denied - user might not be fully authenticated yet
        if (e.code != 'permission-denied') {
          debugPrint("Error fetching user data: $e");
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
      }
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    try {
      debugPrint('[AuthManager] Starting signup for email: $email');
      
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Validate user was created
      if (userCredential.user == null) {
        throw 'Failed to create user account. Please try again.';
      }

      debugPrint('[AuthManager] User created with UID: ${userCredential.user!.uid}');

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[AuthManager] User document saved to Firestore');

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      debugPrint('[AuthManager] Verification email sent to $email');

      // For development/testing: Keep user logged in so they can use the app immediately
      // In production, you might want to enforce email verification
      // await _auth.signOut();
      // _user = null;
      // _userData = null;
      // notifyListeners();
      
      // Instead, fetch user data and keep them logged in
      await _fetchUserData();
      _user = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthManager] FirebaseAuthException caught: ${e.code} - ${e.message}');
      
      // Handle specific Firebase Auth errors
      String errorMessage = 'An error occurred during sign up.';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered. Please use a different email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid. Please check and try again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use a stronger password.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'captcha-check-failed':
          errorMessage = 'Security verification failed. Please check your internet connection and try again.';
          break;
        case 'configuration-not-found':
          errorMessage = 'App security configuration error. This issue is being resolved. Please try again in a moment.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
      
      debugPrint('[AuthManager] Error message: $errorMessage');
      throw errorMessage;
    } catch (e) {
      debugPrint('[AuthManager] Non-Firebase error: $e');
      // Handle any other errors
      String errorMessage = 'An unexpected error occurred during sign up.';
      if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
        errorMessage = 'Security configuration error. Please try again or contact support.';
      }
      throw errorMessage;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        // Sign out the user and throw an error requiring email verification
        await _auth.signOut();
        throw 'Email not verified. Please check your inbox for the verification email and click the link to verify your account.';
      }
      
      // If email is verified, update user data
      await _fetchUserData();
      _user = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign in.';
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact support.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please check your email or sign up.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
      
      throw errorMessage;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    if (_user != null) {
      try {
        debugPrint('[AuthManager] Updating user name: $newName');
        await _firestore.collection('users').doc(_user!.uid).update({
          'name': newName,
        });
        debugPrint('[AuthManager] Name updated successfully');
        await _fetchUserData();
      } on FirebaseException catch (e) {
        debugPrint('[AuthManager] Firebase error updating name: ${e.code} - ${e.message}');
        throw 'Failed to update name: ${e.message ?? 'Unknown error'}';
      } catch (e) {
        debugPrint('[AuthManager] Error updating name: $e');
        throw 'Failed to update name. Please try again.';
      }
    } else {
      throw 'No user logged in';
    }
  }

  Future<void> updatePhone(String newPhone) async {
    if (_user != null) {
      try {
        debugPrint('[AuthManager] Updating user phone: $newPhone');
        await _firestore.collection('users').doc(_user!.uid).update({
          'phoneNumber': newPhone,
        });
        debugPrint('[AuthManager] Phone updated successfully');
        await _fetchUserData();
      } on FirebaseException catch (e) {
        debugPrint('[AuthManager] Firebase error updating phone: ${e.code} - ${e.message}');
        throw 'Failed to update phone: ${e.message ?? 'Unknown error'}';
      } catch (e) {
        debugPrint('[AuthManager] Error updating phone: $e');
        throw 'Failed to update phone. Please try again.';
      }
    } else {
      throw 'No user logged in';
    }
  }

  Future<void> updateLocation(String newLocation) async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).set({
          'location': newLocation,
        }, SetOptions(merge: true));
        await _fetchUserData();
      } catch (e) {
        debugPrint("Failed to update location: $e");
        throw 'Failed to update location.';
      }
    }
  }

  Future<void> resendVerificationEmail(String email, String password) async {
    try {
      // We need to sign in to send the verification email if the user is not logged in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        debugPrint('[AuthManager] Verification email resent successfully');
        // Sign out after sending to prevent permission errors
        await _auth.signOut();
        _user = null;
        _userData = null;
        notifyListeners();
        // Return early to avoid signing out again
        return;
      } else {
        // Already verified - sign out and notify
        await _auth.signOut();
        _user = null;
        _userData = null;
        notifyListeners();
        debugPrint('[AuthManager] Email is already verified');
        throw 'Email is already verified.';
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to resend verification email.';
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        default:
          errorMessage = 'Failed to resend verification email. Please try again.';
      }
      
      throw errorMessage;
    }
  }

  bool isAdmin() {
    return _userData != null && _userData!['userRole'] == 'admin';
  }

  bool isEmailVerified() {
    return _user?.emailVerified ?? false;
  }

  Future<bool> checkEmailVerificationStatus() async {
    if (_user != null) {
      try {
        // Reload user to get latest email verification status
        await _user!.reload();
        _user = FirebaseAuth.instance.currentUser;
        final isVerified = _user?.emailVerified ?? false;
        debugPrint('[AuthManager] Email verification status: $isVerified for ${_user?.email}');
        notifyListeners();
        return isVerified;
      } catch (e) {
        debugPrint('[AuthManager] Error checking email verification status: $e');
        return false;
      }
    }
    return false;
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during password reset.';
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        default:
          errorMessage = e.message ?? errorMessage;
      }
      
      throw errorMessage;
    } catch (e) {
      throw 'An error occurred during password reset.';
    }
  }
}