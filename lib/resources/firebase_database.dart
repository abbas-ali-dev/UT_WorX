import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ut_worx/screen_models/user_model.dart';

class FirebaseDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch user details
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      var userDoc = await _firestore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  // Stream to fetch user details
  Stream<UserModel?> getUserStream() {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      });
    }
    return Stream.value(null);
  }
}
