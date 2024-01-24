import 'package:flutter/material.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';
import 'package:matrimonial/services/user_service/friend_request_service.dart';
import 'package:matrimonial/widget/friend_request_card.dart';

class FriendRequestBottomSheet extends StatelessWidget {
  final String userId;

  FriendRequestBottomSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FriendRequestPage(userId: userId),
      ),
    );
  }
}

class FriendRequestPage extends StatefulWidget {
  final String userId;

  FriendRequestPage({required this.userId});

  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final FriendRequestService _friendRequestService = FriendRequestService();
  late Future<List<User>> _savedUsersFuture;

  @override
  void initState() {
    super.initState();
    _savedUsersFuture =
        _friendRequestService.getUsersWithFriendRequests(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Requests'),
      ),
      body: FutureBuilder<List<User>>(
        future: _savedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved users found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return RequestCard(user: user); // Use your RequestCard widget
              },
            );
          }
        },
      ),
    );
  }
}
