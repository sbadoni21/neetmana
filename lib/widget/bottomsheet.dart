import 'package:flutter/material.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';

class SavedUsersBottomSheet extends StatelessWidget {
  final String userId;

  SavedUsersBottomSheet({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SavedUsersPage(userId: userId),
      ),
    );
  }
}

class SavedUsersPage extends StatefulWidget {
  final String userId;

  SavedUsersPage({required this.userId});

  @override
  _SavedUsersPageState createState() => _SavedUsersPageState();
}

class _SavedUsersPageState extends State<SavedUsersPage> {
  final BookmarkService _bookmarkService = BookmarkService();
  late Future<List<User>> _savedUsersFuture;

  @override
  void initState() {
    super.initState();
    _savedUsersFuture = _bookmarkService.getSavedUsers(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Users'),
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
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.photoURL),
                  ),
                  title: Text(user.displayName),
                  subtitle: Text(user.dob),
                  onTap: () {
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
