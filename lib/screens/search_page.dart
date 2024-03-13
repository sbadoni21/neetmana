import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/screens/otherUser_detailpage.dart';
import 'package:matrimonial/services/user_service/user_service.dart';
import 'package:matrimonial/widget/user_card.dart';

class UserSearchPage extends ConsumerStatefulWidget {
  UserSearchPage();

  @override
  _UserSearchPageState createState() => _UserSearchPageState();
}

class _UserSearchPageState extends ConsumerState<UserSearchPage> {
  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    User? user = ref.read(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: UserService().filterUsers(user!, _searchController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<User> filteredUsers = snapshot.data ?? [];
                  return filteredUsers.isEmpty
                      ? Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OtherUserProfilePage(
                                                user: filteredUsers[index])));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: UserCard(user: filteredUsers[index]),
                              ),
                            );
                          },
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
