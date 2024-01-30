import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';
import 'package:matrimonial/widget/saved_preference_tile.dart.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class SavedPreferences extends ConsumerStatefulWidget {
  const SavedPreferences({Key? key}) : super(key: key);

  @override
  _SavedPreferencesState createState() => _SavedPreferencesState();
}

class _SavedPreferencesState extends ConsumerState<SavedPreferences> {
  final BookmarkService _bookmarkService = BookmarkService();
  late Future<List<User>> _savedUsersFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    User? user = ref.watch(userProvider);
    _savedUsersFuture = _bookmarkService.getSavedUsers(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Preferences'),
      ),
      body: FutureBuilder<List<User>>(
        future: _savedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No saved preferences.'));
          } else {
            List<User> savedUsers = snapshot.data!;
            return _buildGridView(savedUsers);
          }
        },
      ),
    );
  }

  Widget _buildGridView(List<User> savedUsers) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 250),
      itemCount: savedUsers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SavedPreferenceTiles(user: savedUsers[index]),
        );
      },
    );
  }
}
