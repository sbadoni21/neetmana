import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrimonial/models/user_model.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSavedUser(String userId, String savedUserId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      await _ensureSavedUsersField(userDocRef);
      await userDocRef.update({
        'savedUsers': FieldValue.arrayUnion([savedUserId]),
      });
    } catch (e) {
      throw Exception("Error adding saved user: $e");
    }
  }

  Future<void> removeSavedUser(String userId, String savedUserId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      await _ensureSavedUsersField(userDocRef);
      await userDocRef.update({
        'savedUsers': FieldValue.arrayRemove([savedUserId]),
      });
    } catch (e) {
      throw Exception("Error removing saved user: $e");
    }
  }

  Future<void> _ensureSavedUsersField(DocumentReference userDocRef) async {
    try {
      final userDocSnapshot = await userDocRef.get();
      final Map<String, dynamic>? userData = userDocSnapshot.data() as Map<String, dynamic>?;

      if (userData == null || !userData.containsKey('savedUsers')) {
        await userDocRef.set({'savedUsers': []}, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception("Error ensuring 'savedUsers' field: $e");
    }
  }

  Future<List<User>> getSavedUsers(String userId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      final userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        final userData = userDocSnapshot.data() as Map<String, dynamic>;

        if (userData.containsKey('savedUsers')) {
          final List<String> savedUserIds = List<String>.from(userData['savedUsers']);
          final List<User> savedUsers = await _getUsersByUserIds(savedUserIds);
          return savedUsers;
        } else {
          return [];
        }
      } else {
        throw Exception("User document not found for ID: $userId");
      }
    } catch (e) {
      throw Exception("Error getting saved users: $e");
    }
  }

  Future<List<User>> _getUsersByUserIds(List<String> userIds) async {
    try {
      final List<User> savedUsers = [];

      for (final userId in userIds) {
        final userDocSnapshot = await _firestore.collection('users').doc(userId).get();

        if (userDocSnapshot.exists) {
          final userData = userDocSnapshot.data() as Map<String, dynamic>;
          final User user = User.fromMap(userData);
          savedUsers.add(user);
        }
      }

      return savedUsers;
    } catch (e) {
      throw Exception("Error getting users by user IDs: $e");
    }
  }
  Future<bool> isUserSaved(String currentUserUid, String otherUserUid) async {
    try {
      final userData = await _firestore.collection('users').doc(currentUserUid).get();
      final List<dynamic>? savedUsers = userData.data()?['savedUsers'] as List<dynamic>?;

      if (savedUsers != null && savedUsers.contains(otherUserUid)) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking if user is saved: $e');
      rethrow;
    }
  }
}
