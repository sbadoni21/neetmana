import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrimonial/models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<User>> getMyContacts(String currentUserUid) async {
    try {
      final userData =
          await _firestore.collection('users').doc(currentUserUid).get();
      final List<dynamic>? myContacts =
          userData.data()?['myContacts'] as List<dynamic>?;

      if (myContacts != null && myContacts.isNotEmpty) {
        final List<User> users = [];

        for (final contactUid in myContacts) {
          final contactData =
              await _firestore.collection('users').doc(contactUid).get();
          final User user = User.fromMap(contactData.data()!);
          users.add(user);
        }

        return users;
      }

      return [];
    } catch (e) {
      print('Error getting my contacts: $e');
      rethrow;
    }
  }
}
