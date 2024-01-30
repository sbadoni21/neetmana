import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/otherUser_detailpage.dart';
import 'package:matrimonial/services/user_service/friend_request_service.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class RequestCard extends ConsumerStatefulWidget {
  final User user;

  RequestCard({required this.user});

  @override
  _RequestCardState createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<RequestCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtherUserProfilePage(user: widget.user)));
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.user.photoURL),
              ),
              title: Text(widget.user.displayName),
              subtitle: Text(widget.user.dob),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _handleAcceptButtonPress,
                  child:const Icon(Icons.done, color: Colors.green)
,
                ),
                ElevatedButton(
                  onPressed: _handleDeclineButtonPress,
                  child:const Icon(Icons.close, color: Colors.red)
,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAcceptButtonPress() async {
    final friendRequestService = FriendRequestService();
    final current = ref.watch(userProvider);

    final currentUser = current;

    if (currentUser != null) {
      try {
        await friendRequestService.acceptFriendRequest(
            currentUser.uid, widget.user.uid);
      } catch (e) {
        print('Error accepting friend request: $e');
      }
    }
  }

  void _handleDeclineButtonPress() async {
    final friendRequestService = FriendRequestService();
    final current = ref.watch(userProvider);

    final currentUser = current;

    if (currentUser != null) {
      try {
        await friendRequestService.declineFriendRequest(
            currentUser.uid, widget.user.uid);
      } catch (e) {
        print('Error declining friend request: $e');
      }
    }
  }
}
