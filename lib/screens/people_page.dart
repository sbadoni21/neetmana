import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/services/user_service/user_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/user_card.dart';

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    return Scaffold(
      // appBar: AppBar(
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text("Welcome ${user!.displayName}"),
      //       SizedBox(
      //         height: 8,
      //       ),
      //       Text(
      //         'Find your perfect match',
      //         style: myTextStylefontsize14Black,
      //       )
      //     ],
      //   ),
      // ),
      body: RefreshIndicator(
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
    );
  }
}
