import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/chatapp_page.dart';
import 'package:matrimonial/screens/people_page.dart';
import 'package:matrimonial/screens/profile_page.dart';
import 'package:matrimonial/screens/saved_preferences.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/bottomsheet.dart';
import 'package:matrimonial/widget/friend_request_sheet.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  User? user;

  final List<Widget> _pages = [
    PeoplePage(),
    SavedPreferences(),
    ProfilePage(),
    ChatAppPage(),
  ];

  @override
  void initState() {
    super.initState();
    user = ref.read(userProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Matrimonial App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              _showSavedUsersBottomSheet(context, user!.uid);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showFriendRequestBottomSheet(context, user!.uid);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: bgColor,
        backgroundColor: bgColor,
        unselectedItemColor: Colors.black,
        elevation: 2,
        enableFeedback: true,
        selectedFontSize: 20,
        unselectedFontSize: 10,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'People',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_add),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
    );
  }

  void _showSavedUsersBottomSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SavedUsersBottomSheet(userId: userId);
      },
    );
  }

  void _showFriendRequestBottomSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FriendRequestBottomSheet(userId: userId);
      },
    );
  }
}
