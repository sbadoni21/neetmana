import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/homepage.dart';
import 'package:matrimonial/screens/otherUser_detailpage.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/bubble.dart';

class UserCard extends ConsumerStatefulWidget {
  final User user;

  UserCard({required this.user});

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard> {
  bool isSaved = false;
  late BookmarkService bookmarkService;

  @override
  void initState() {
    super.initState();
    bookmarkService = BookmarkService();
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
                    topRight: Radius.elliptical(50, 50),
                  ),
                  child: widget.user.photoURL != "none"
                      ? Image.network(
                          widget.user.photoURL,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/placeholder_image.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
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
                              ? _onUnsaveButtonPressed(ref.read(userProvider))
                              : _onSaveButtonPressed(ref.read(userProvider));
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

  void _onSaveButtonPressed(User? currentUser) async {
    if (currentUser != null) {
      await bookmarkService.addSavedUser(currentUser.uid, widget.user.uid);
      if (mounted) {
        setState(() {
          isSaved = true;
        });
      }
    }
  }

  void _onUnsaveButtonPressed(User? currentUser) async {
    if (currentUser != null) {
      await bookmarkService.removeSavedUser(currentUser.uid, widget.user.uid);
      if (mounted) {
        setState(() {
          isSaved = false;
        });
      }
    }
  }

  void _checkIfUserIsSaved() async {
    final currentUser = ref.read(userProvider);
    if (currentUser != null) {
      final saved =
          await bookmarkService.isUserSaved(currentUser.uid, widget.user.uid);
      if (mounted) {
        setState(() {
          isSaved = saved;
        });
      }
    }
  }
}
