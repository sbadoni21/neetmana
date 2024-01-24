import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> updateUserProfile({
    required String displayName,
    required String phoneNumber,
  }) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'displayName': displayName,
          'phoneNumber': phoneNumber,
        });
      }
    } catch (e) {
      print('Error updating user profile: $e');
    }

    return null;
  }
}
