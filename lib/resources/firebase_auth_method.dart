import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up method
  Future<String> signUpUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    String res = "error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          confirmPassword.isNotEmpty ||
          role.isNotEmpty) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // add user to the database
        await _firestore.collection('Users').doc(cred.user!.uid).set({
          'email': email,
          'password': password,
          'uid': cred.user!.uid,
          'role': role,
        });
        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // logging in user
  Future<User?> loginInUser({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userDoc = await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data()!['role'] == role) {
        return userCredential.user;
      } else {
        await signOut();
        return null;
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors (optional but recommended)
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      return null; // Return null on failure
    } catch (e) {
      debugPrint('General Login Error: $e');
      return null; // Return null on failure
    }
  }

// reset password
  Future<String> resetPassword({required String email}) async {
    String res = "Some error occurred";
    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found with this email';
      } else {
        res = e.message ?? "An error occurred";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
