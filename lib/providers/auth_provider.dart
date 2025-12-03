import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  AuthProvider() {
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      // Sign out immediately so they can't access the app until verified
      await _auth.signOut();
      _user = null;
      _userData = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign up.';
    } catch (e) {
      throw 'An error occurred during sign up.';
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        throw 'Email not verified. Please check your inbox.';
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during sign in.';
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateName(String newName) async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).update({
          'name': newName,
        });
        await _fetchUserData();
      } catch (e) {
        throw 'Failed to update name.';
      }
    }
  }

  Future<void> updatePhone(String newPhone) async {
    if (_user != null) {
      try {
        await _firestore.collection('users').doc(_user!.uid).update({
          'phoneNumber': newPhone,
        });
        await _fetchUserData();
      } catch (e) {
        throw 'Failed to update phone number.';
      }
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
        await _auth.signOut();
      } else {
        // Already verified
        await _auth.signOut();
        throw 'Email is already verified.';
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to resend verification email.';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred during password reset.';
    } catch (e) {
      throw 'An error occurred during password reset.';
    }
  }
}
