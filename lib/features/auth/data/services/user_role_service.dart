import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> getUserRole() async {
    try {
      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return 'user';

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      // Return role if exists, otherwise default to 'user'
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      print('Error fetching user role: $e');
      return 'user';
    }
  }

  // Method to create user role during signup
  Future<void> createUserRole(String uid, {String role = 'user'}) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user role: $e');
    }
  }
}
