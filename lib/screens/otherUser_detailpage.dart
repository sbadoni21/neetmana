import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';
import 'package:matrimonial/services/user_service/friend_request_service.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class OtherUserProfilePage extends ConsumerStatefulWidget {
  final User user;

  OtherUserProfilePage({required this.user});

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends ConsumerState<OtherUserProfilePage> {
  late bool friendRequestSent;
  User? currentUser;
  bool isFriend = false;
  late bool isSaved = false;
  final BookmarkService bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
    friendRequestSent = false;
    isFriend = false;
    isSaved = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = ref.read(userProvider);
    checkFriendshipStatus();
    checkSavedStatus();
  }

  void checkFriendshipStatus() {
    if (currentUser != null) {
      final friendRequestService = FriendRequestService();
      final isFriendFuture = friendRequestService.areFriends(
        currentUser!.uid,
        widget.user.uid,
      );

      isFriendFuture.then((value) {
        setState(() {
          isFriend = value;
        });
      }).catchError((error) {
        print('Error checking friendship status: $error');
      });
    }
  }

  void checkSavedStatus() async {
    final currentUser = ref.read(userProvider);
    if (currentUser != null) {
      final saved =
          await bookmarkService.isUserSaved(currentUser.uid, widget.user.uid);
      setState(() {
        isSaved = saved;
      });
    }
  }

  void _onSaveButtonPressed() async {
    if (currentUser != null) {
      await bookmarkService.addSavedUser(currentUser!.uid, widget.user.uid);
      setState(() {
        isSaved = true;
      });
    }
  }

  void _onUnsaveButtonPressed() async {
    if (currentUser != null) {
      await bookmarkService.removeSavedUser(currentUser!.uid, widget.user.uid);
      setState(() {
        isSaved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.displayName),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              height: 194,
              child: Row(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.user.photoURL),
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(widget.user.displayName),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(widget.user.occupation),
                            Text(widget.user.dob),
                            Text(widget.user.currentLocation)
                          ],
                        ),
                        ElevatedButton(
                          onPressed: isFriend
                              ? () {
                                  _unfriendAction();
                                }
                              : friendRequestSent
                                  ? () {
                                      _removeFriendRequest();
                                    }
                                  : () {
                                      _sendFriendRequest();
                                    },
                          child: Text(
                            isFriend
                                ? 'Unfriend'
                                : friendRequestSent
                                    ? 'Cancel Connect'
                                    : 'Connect',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: isSaved
                        ? Icon(Icons.bookmark, color: Colors.red)
                        : Icon(Icons.bookmark_outline),
                    onPressed: () {
                      isSaved
                          ? _onUnsaveButtonPressed()
                          : _onSaveButtonPressed();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildInfoRow('Display Name', widget.user.displayName),
            SizedBox(height: 10),
            _buildInfoRow('Email', widget.user.email),
            SizedBox(height: 10),
            _buildInfoRow('Phone Number', widget.user.phoneNumber),
            SizedBox(height: 10),
            _buildInfoRow('Status', widget.user.status),
            SizedBox(height: 10),
            _buildInfoRow('Gender', widget.user.gender),
            SizedBox(height: 10),
            _buildInfoRow('Occupation', widget.user.occupation),
            SizedBox(height: 10),
            _buildInfoRow('Current Location', widget.user.currentLocation),
            SizedBox(height: 10),
            _buildInfoRow('Date of Birth', widget.user.dob),
            SizedBox(height: 10),
            _buildInfoRow('Native Village', widget.user.nativeVillage),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _sendFriendRequest() {
    final friendRequestService = FriendRequestService();
    final currentUser = ref.read(userProvider);

    if (currentUser != null) {
      try {
        friendRequestService.sendFriendRequest(
            currentUser.uid, widget.user.uid);
        setState(() {
          friendRequestSent = true;
        });
      } catch (e) {
        print('Error sending friend request: $e');
      }
    }
  }

  void _removeFriendRequest() {
    final friendRequestService = FriendRequestService();
    final currentUser = ref.read(userProvider);

    if (currentUser != null) {
      try {
        friendRequestService.removeFriendRequest(
            currentUser.uid, widget.user.uid);
        setState(() {
          friendRequestSent = false;
        });
      } catch (e) {
        print('Error removing friend request: $e');
        // Handle error if needed
      }
    }
  }

  void _unfriendAction() {
    final friendshipService = FriendRequestService();

    if (currentUser != null) {
      try {
        friendshipService.removeFriend(currentUser!.uid, widget.user.uid);
        setState(() {
          isFriend = false;
        });
      } catch (e) {
        print('Error unfriending user: $e');
        // Handle error if needed
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent[100],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
