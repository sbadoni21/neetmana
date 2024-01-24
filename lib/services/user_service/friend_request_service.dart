import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrimonial/models/user_model.dart';

class FriendRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(
      String currentUserUid, String otherUserUid) async {
    try {
      await _createUserFieldsIfNotExists(currentUserUid);
      await _createUserFieldsIfNotExists(otherUserUid);

      final currentUserDoc =
          await _firestore.collection('users').doc(currentUserUid).get();
      final List<dynamic>? myRequests =
          currentUserDoc.data()?['myRequests'] as List<dynamic>?;

      if (myRequests != null && myRequests.contains(otherUserUid)) {
        print('Friend request already sent');
        return;
      }

      await _firestore.collection('users').doc(currentUserUid).update({
        'myRequests': FieldValue.arrayUnion([otherUserUid]),
      });

      await _firestore.collection('users').doc(otherUserUid).update({
        'requestedUsers': FieldValue.arrayUnion([currentUserUid]),
      });
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  Future<void> removeFriendRequest(
      String currentUserUid, String otherUserUid) async {
    try {
      await _firestore.collection('users').doc(currentUserUid).update({
        'myRequests': FieldValue.arrayRemove([otherUserUid]),
      });

      await _firestore.collection('users').doc(otherUserUid).update({
        'requestedUsers': FieldValue.arrayRemove([currentUserUid]),
      });
    } catch (e) {
      print('Error removing friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(
      String currentUserUid, String otherUserUid) async {
    try {
      await _createUserFieldsIfNotExists(currentUserUid);
      await _createUserFieldsIfNotExists(otherUserUid);
      await _firestore.collection('users').doc(currentUserUid).update({
        'requestedUsers': FieldValue.arrayRemove([otherUserUid]),
      });
      await _firestore.collection('users').doc(otherUserUid).update({
        'myRequests': FieldValue.arrayRemove([currentUserUid]),
      });

      await _firestore.collection('users').doc(currentUserUid).update({
        'myContacts': FieldValue.arrayUnion([otherUserUid]),
      });

      await _firestore.collection('users').doc(otherUserUid).update({
        'myContacts': FieldValue.arrayUnion([currentUserUid]),
      });
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> declineFriendRequest(
      String currentUserUid, String otherUserUid) async {
    try {
      await _firestore.collection('users').doc(currentUserUid).update({
        'requestedUsers': FieldValue.arrayRemove([otherUserUid]),
      });
      await _firestore.collection('users').doc(otherUserUid).update({
        'myRequests': FieldValue.arrayRemove([currentUserUid]),
      });
    } catch (e) {
      print('Error declining friend request: $e');
      rethrow;
    }
  }

  Future<void> _createUserFieldsIfNotExists(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      await userDoc.set({
        'myRequests': [],
        'requestedUsers': [],
        'myContacts': [],
      });
    }
  }

  Future<List<User>> getUsersWithFriendRequests(String userId) async {
    try {
      List<String> friendRequestIds =
          await getUserIdsWithFriendRequests(userId);

      List<User> users = [];

      for (String friendRequestId in friendRequestIds) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(friendRequestId).get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          User user = User.fromMap(userData);
          users.add(user);
        }
      }

      return users;
    } catch (e) {
      print('Error fetching users with friend requests: $e');
      return [];
    }
  }

  Future<List<String>> getUserIdsWithFriendRequests(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('requestedUsers')) {
          List<dynamic> myRequestList = userData['requestedUsers'];
          List<String> userIds = List<String>.from(myRequestList);
          return userIds;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching user IDs: $e');
      return [];
    }
  }

  Future<void> sendMessage(
      String senderId, String recipientId, String text) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': senderId,
        'recipientId': recipientId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<List<ChatMessage>> getMessages(
      String currentUserUid, String otherUserUid) {
    return _firestore
        .collection('messages')
        .where('senderId', arrayContainsAny: [currentUserUid, otherUserUid])
        .where('recipientId', arrayContainsAny: [currentUserUid, otherUserUid])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ChatMessage(
              senderId: data['senderId'],
              text: data['text'],
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }
}
