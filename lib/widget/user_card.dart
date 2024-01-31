import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/otherUser_detailpage.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/bubble.dart';

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
  late bool isSaved = false;
  final bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfUserIsSaved();
  }

  String calculateAgeString(String dob) {
    List<String> dobParts = dob.split('/');
    int day = int.parse(dobParts[0]);
    int month = int.parse(dobParts[1]);
    int year = int.parse(dobParts[2]);

    DateTime today = DateTime.now();
    DateTime birthDate = DateTime(year, month, day);

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    final userService = BookmarkService();
    final currentUser = ref.watch(userProvider);
    String ageString = calculateAgeString(widget.user.dob);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtherUserProfilePage(user: widget.user),
          ),
        );
      },
      child: Material(
        elevation: 1,
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: 100,
                  width: 120,
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.elliptical(50, 50),
                          topRight: Radius.elliptical(50, 50)),
                      child: widget.user.photoURL != "none"
                          ? Image.network(
                              widget.user.photoURL,
                              fit: BoxFit.fill,
                            )
                          : Image.asset(
                              'assets/images/placeholder_image.png'))),
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(
                          widget.user.displayName,
                          style: myTextStylefontsize16,
                        ),
                      ),
                      IconButton(
                        icon: isSaved
                            ? Icon(Icons.bookmark, color: Colors.red)
                            : Icon(Icons.bookmark_border_outlined),
                        onPressed: () {
                          isSaved
                              ? _onUnsaveButtonPressed(userService, currentUser)
                              : _onSaveButtonPressed(userService, currentUser);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Bubble(text: widget.user.occupation),
                      const SizedBox(
                        width: 4,
                      ),
                      Bubble(text: "$ageString years"),
                      const SizedBox(
                        width: 4,
                      ),
                      // Bubble(text: '${widget.user.nativeVillage}'),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveButtonPressed(
      BookmarkService userService, User? currentUser) async {
    if (currentUser != null) {
      await userService.addSavedUser(currentUser.uid, widget.user.uid);
      setState(() {
        isSaved = true;
      });
    }
  }

  void _onUnsaveButtonPressed(
      BookmarkService userService, User? currentUser) async {
    if (currentUser != null) {
      await userService.removeSavedUser(currentUser.uid, widget.user.uid);
      setState(() {
        isSaved = false;
      });
    }
  }

  void _checkIfUserIsSaved() async {
    final currentUser = ref.read(userProvider);
    if (currentUser != null) {
      final saved =
          await bookmarkService.isUserSaved(currentUser.uid, widget.user.uid);
      setState(() {
        isSaved = saved;
      });
    }
  }
}



//  Container(
//         height: 100,
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage(widget.user.photoURL),
//           ),
//           title: Text(
//             widget.user.displayName,
//             style: myTextStylefontsize16,
//           ),
//           subtitle: Row(
//             children: [
//               Bubble(text: widget.user.occupation),
//               SizedBox(
//                 width: 4,
//               ),
//               Bubble(text: "$ageString years")
//             ],
//           ),
//           trailing: 
// IconButton(
//             icon: isSaved
//                 ? Icon(Icons.bookmark, color: Colors.red)
//                 : Icon(Icons.bookmark_border_outlined),
//             onPressed: () {
//               isSaved
//                   ? _onUnsaveButtonPressed(userService, currentUser)
//                   : _onSaveButtonPressed(userService, currentUser);
//             },
//           ),
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OtherUserProfilePage(user: widget.user),
//               ),
//             );
//           },
//         ),
//       ),}