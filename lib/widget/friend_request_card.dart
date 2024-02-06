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
  bool isLoading = false;
  int trigger = 0;
  Widget build(BuildContext context) {
    return isLoading ? buildWithLoadingIndicator() : buildCard();
  }

  Widget buildCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfilePage(user: widget.user),
          ),
        );
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
            trigger == 0
                ? ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleAcceptButtonPress,
                        child: Icon(Icons.done, color: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleDeclineButtonPress,
                        child: Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget buildWithLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  void _handleAcceptButtonPress() async {
    final friendRequestService = FriendRequestService();
    final current = ref.watch(userProvider);
    final currentUser = current;

    if (currentUser != null) {
      try {
        setState(() {
          isLoading = true;
          trigger = 1;
        });

        await friendRequestService.acceptFriendRequest(
          currentUser.uid,
          widget.user.uid,
        );
      } catch (e) {
        print('Error accepting friend request: $e');
      } finally {
        setState(() {
          isLoading = false;
          trigger = 1;
        });
      }
    }
  }

  void _handleDeclineButtonPress() async {
    final friendRequestService = FriendRequestService();
    final current = ref.watch(userProvider);
    final currentUser = current;

    if (currentUser != null) {
      try {
        setState(() {
          isLoading = true;
        });

        await friendRequestService.declineFriendRequest(
          currentUser.uid,
          widget.user.uid,
        );
      } catch (e) {
        print('Error declining friend request: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
