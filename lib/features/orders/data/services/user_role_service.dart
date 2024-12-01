import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserRole() async {
    try {
      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user found');
        return 'user';
      }

      debugPrint('Attempting to fetch role for UID: ${currentUser.uid}');

      // Attempt to get document with different strategies
      List<Source> sourcesToTry = [
        Source.server,
        Source.cache,
      ];

      for (var source in sourcesToTry) {
        try {
          final docSnapshot = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get(GetOptions(source: source));

          if (docSnapshot.exists) {
            final data = docSnapshot.data();
            debugPrint('Document data from $source: $data');
            
            String role = data?['role'] ?? 'user';
            debugPrint('Retrieved role from $source: $role');
            return role;
          }
        } catch (e) {
          debugPrint('Error fetching role from $source: $e');
        }
      }

      // Fallback to default role
      debugPrint('No role found, defaulting to user');
      return 'user';
    } catch (e) {
      debugPrint('Comprehensive Error fetching user role: $e');
      return 'user';
    }
  }

  // Method to manually set or update user role
  Future<void> setUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('User role set to $role for UID: $uid');
    } catch (e) {
      debugPrint('Error setting user role: $e');
    }
  }

  // Method to check Firestore connectivity with multiple attempts
  Future<bool> checkFirestoreConnection() async {
    List<Source> sourcesToTry = [
      Source.server,
      Source.cache,
    ];

    for (var source in sourcesToTry) {
      try {
        await _firestore
            .collection('users')
            .limit(1)
            .get(GetOptions(source: source));
        debugPrint('Firestore connection successful with $source');
        return true;
      } catch (e) {
        debugPrint('Firestore connection check failed for $source: $e');
      }
    }
    
    debugPrint('All Firestore connection attempts failed');
    return false;
  }

  // Diagnostic method to print out current user details
  Future<void> printCurrentUserDetails() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('No current user logged in');
        return;
      }

      debugPrint('Current User Details:');
      debugPrint('UID: ${currentUser.uid}');
      debugPrint('Email: ${currentUser.email}');
      debugPrint('Display Name: ${currentUser.displayName}');
      
      // Attempt to fetch user document
      try {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (docSnapshot.exists) {
          debugPrint('User Document Data: ${docSnapshot.data()}');
        } else {
          debugPrint('No user document found');
        }
      } catch (e) {
        debugPrint('Error fetching user document: $e');
      }
    } catch (e) {
      debugPrint('Error printing user details: $e');
    }
  }
}
