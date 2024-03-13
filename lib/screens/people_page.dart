import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/search_page.dart';
import 'package:matrimonial/services/user_service/user_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/user_card.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class PeoplePage extends ConsumerStatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends ConsumerState<PeoplePage> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _usersFuture = UserService().getUsers(user!.uid, user.gender);
  }

  Future<void> _refreshUsers() async {
    final user = ref.read(userProvider);
    setState(() {
      _usersFuture = UserService().getUsers(user!.uid, user.gender);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                ),
                Text(
                  "Welcome ...",
                  style: myTextStylefontsize24BGCOLOR,
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "${user!.displayName}",
                  style: myTextStylefontsize24Black,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  'Find your perfect match',
                  style: myTextStylefontsize20BGCOLOR,
                ),
                SizedBox(
                  height: 8,
                ),
                _buildSearchBar()
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUsers,
              child: FutureBuilder(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      (snapshot.data as List<User>).isEmpty) {
                    return Center(child: Text('No users found.'));
                  } else {
                    List<User> users = snapshot.data as List<User>;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          child: UserCard(
                            user: users[index],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserSearchPage()));
            },
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            'Search',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          DefaultTextStyle(
                            style: myTextStylefontsize12Black,
                            child: AnimatedTextKit(
                              isRepeatingAnimation: true,
                              repeatForever: true,
                              animatedTexts: [
                                RotateAnimatedText(
                                  'Doctors',
                                ),
                                RotateAnimatedText('Native Village'),
                                RotateAnimatedText('Educational Background'),
                                RotateAnimatedText('Cureent Location'),


                              ],
                              onTap: () {
                                print("Tap Event");
                              },
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.search)
                    ]),
              ),
            )));
  }
}
