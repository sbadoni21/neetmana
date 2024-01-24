import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrimonial/models/message_model.dart';
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

        print('My Contacts: $users');
        return users;
      }

      print('No contacts found for user $currentUserUid');
      return [];
    } catch (e) {
      print('Error getting my contacts: $e');
      rethrow;
    }
  }
      final Timestamp timestamp = Timestamp.now();
       Future<void> sendMessage(
      String receiverId, String currentUserId, String message, String type) async {
    final Timestamp timestamp = Timestamp.now();
    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
      type: type,
      seen: false,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  void markAsSeen(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    QuerySnapshot snapshot = await _firestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .where("seen", isEqualTo: false)
        .get();
    await Future.delayed(Duration(seconds: 3));
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      doc.reference.update({'seen': true});
    }
  }
}
