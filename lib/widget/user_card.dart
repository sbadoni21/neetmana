import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/otherUser_detailpage.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class UserCard extends ConsumerStatefulWidget {
  final User user;

  UserCard({required this.user});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard> {
  @override
  Widget build(BuildContext context,) {
    final current = ref.watch(userProvider);

    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(widget.user.photoURL),
        ),
        title: Text(widget.user.displayName),
        subtitle: Text(widget.user.dob),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final userService = BookmarkService();
            final currentUser = current;
            if (currentUser != null) {
              if (value == 'save') {
                await userService.addSavedUser(
                    currentUser.uid, widget.user.uid);
              } else if (value == 'unsave') {
                await userService.removeSavedUser(
                    currentUser.uid, widget.user.uid);
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'save',
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(Icons.save),
                title: Text('Save'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'unsave',
              child: ListTile(
                style: ListTileStyle.list,
                leading: Icon(Icons.delete),
                title: Text('Unsave'),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserProfilePage(user: widget.user),
            ),
          );
        },
      ),
    );
  }
}
