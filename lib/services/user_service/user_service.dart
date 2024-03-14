import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrimonial/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<User>> getUsers(
    String currentUserId,
    String currentUserGender,
  ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('gender', isNotEqualTo: currentUserGender)
          .get();

      List<User> users = querySnapshot.docs
          .where((doc) =>
              doc.id != currentUserId &&
              doc.exists &&
              (doc.data() as Map<String, dynamic>)
                  .values
                  .every((value) => value != null && value != ""))
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }

  Future<List<User>> filterUsers(User user, String query) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('gender', isNotEqualTo: user.gender)
          .get();

      List<User> users = querySnapshot.docs
          .where((doc) => doc.id != user.uid && doc.exists)
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return users
          .where((user) =>
              user.displayName.toLowerCase().contains(query.toLowerCase()) ||
              user.phoneNumber.toLowerCase().contains(query.toLowerCase()) ||
              user.occupation.toLowerCase().contains(query.toLowerCase()) ||
              user.education.toLowerCase().contains(query.toLowerCase()) ||
              user.guardianName.toLowerCase().contains(query.toLowerCase()) ||
              user.nativeVillage.toLowerCase().contains(query.toLowerCase()) ||
              user.currentLocation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print("Error filtering users: $e");
      return [];
    }
  }
}
