import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrimonial/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<User>> getUsers(String currentUserId, String currentUserGender,
     ) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('gender', isNotEqualTo: currentUserGender)
          .get();

      List<User> users = querySnapshot.docs
          .where((doc) => doc.id != currentUserId && doc.exists)
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }
}
