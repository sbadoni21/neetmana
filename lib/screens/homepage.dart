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
import 'package:matrimonial/widget/custom_bottom_navbar.dart';
import 'package:matrimonial/widget/friend_request_sheet.dart';
import 'package:matrimonial/widget/heading_component.dart';

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
        toolbarHeight: 75,
        backgroundColor: bgColor,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Niti Mana',
              style: myTextStylefontsize20White,
            ),
            Text(
              'JeevanSaathi',
              style: myTextStylefontsize16white,
            ),
          ],
        ),
        leading: Image.asset(
          logo,
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            onPressed: () {
              _showFriendRequestBottomSheet(context, user!.uid);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
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

void _showFriendRequestBottomSheet(BuildContext context, String userId) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return FriendRequestBottomSheet(userId: userId);
    },
  );
}
