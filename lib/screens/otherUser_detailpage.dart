import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/chatpage.dart';
import 'package:matrimonial/screens/homepage.dart';
import 'package:matrimonial/screens/profile_page.dart';
import 'package:matrimonial/services/user_service/bookmark_service.dart';
import 'package:matrimonial/services/user_service/friend_request_service.dart';
import 'package:matrimonial/services/user_service/image_upload_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/heading_component.dart';

class OtherUserProfilePage extends ConsumerStatefulWidget {
  final User user;

  OtherUserProfilePage({required this.user});

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends ConsumerState<OtherUserProfilePage> {
  late bool friendRequestSent;
  User? currentUser;
  bool isFriend = false;
  late bool isSaved = false;
  final BookmarkService bookmarkService = BookmarkService();

  @override
  void initState() {
    super.initState();
    friendRequestSent = false;
    isFriend = false;
    isSaved = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = ref.read(userProvider);
    checkFriendshipStatus();
    checkSavedStatus();
  }

  void checkFriendshipStatus() {
    if (currentUser != null) {
      final friendRequestService = FriendRequestService();
      final isFriendFuture = friendRequestService.areFriends(
        currentUser!.uid,
        widget.user.uid,
      );

      isFriendFuture.then((value) {
        setState(() {
          isFriend = value;
        });
      }).catchError((error) {
        print('Error checking friendship status: $error');
      });
    }
  }

  void checkSavedStatus() async {
    final currentUser = ref.read(userProvider);
    if (currentUser != null) {
      final saved =
          await bookmarkService.isUserSaved(currentUser.uid, widget.user.uid);
      setState(() {
        isSaved = saved;
      });
    }
  }

  void _onSaveButtonPressed() async {
    if (currentUser != null) {
      await bookmarkService.addSavedUser(currentUser!.uid, widget.user.uid);
      setState(() {
        isSaved = true;
      });
    }
  }

  void _onUnsaveButtonPressed() async {
    if (currentUser != null) {
      await bookmarkService.removeSavedUser(currentUser!.uid, widget.user.uid);
      setState(() {
        isSaved = false;
      });
    }
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
    final imageServices = ref.watch(imageServiceProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.user.displayName,
          style: myTextStylefontsize24,
        ),
        backgroundColor: bgColor,
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                  ),
                  Positioned(
                    left: 20,
                    top: 40,
                    child: Container(
                      width: 144,
                      height: 144,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: (widget.user.photoURL != "" &&
                              widget.user.photoURL != 'none')
                          ? Image.network(
                              widget.user.photoURL,
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/images/placeholder_image.png'),
                    ),
                  ),
                  Positioned(
                    left: 180,
                    top: 80,
                    child: SizedBox(
                      width: 120,
                      child: Text(
                        widget.user.displayName,
                        style: myTextStylefontsize16white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 180,
                    top: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.occupation,
                          style: myTextStylefontsize14White,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$ageString years',
                          style: myTextStylefontsize14White,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 75,
                    child: IconButton(
                      icon: isSaved
                          ? Icon(Icons.bookmark, color: Colors.white)
                          : Icon(Icons.bookmark_outline, color: Colors.white),
                      onPressed: () {
                        isSaved
                            ? _onUnsaveButtonPressed()
                            : _onSaveButtonPressed();
                      },
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 155,
                    child: ElevatedButton(
                      onPressed: isFriend
                          ? () {
                              _unfriendAction();
                            }
                          : friendRequestSent
                              ? () {
                                  _removeFriendRequest();
                                }
                              : () {
                                  _sendFriendRequest();
                                },
                      child: Text(
                        isFriend
                            ? 'Unfriend'
                            : friendRequestSent
                                ? 'Cancel Connect'
                                : 'Connect',
                      ),
                    ),
                  ),
                  Positioned(
                      right: 120,
                      top: 221,
                      child: Text(
                        ' Profile Maintained by ${widget.user.role} ',
                        style: myTextStylefontsize14White,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
              child: HeadingTitle(title: 'Images'),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5, 20, 5),
              child: FutureBuilder(
                future: imageServices.getUserImages(widget.user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('No Images added'));
                  } else {
                    List<String> fetchedImages = snapshot.data as List<String>;

                    return SizedBox(
                      height: 170,
                      child: fetchedImages.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fetchedImages.length,
                              itemBuilder: (context, index) {
                                String image = fetchedImages[index];
                                return GestureDetector(
                                  onTap: () {
                                    _showImageDialog(
                                      image,
                                      context,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    child: SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: Stack(
                                        children: [
                                          ClipRect(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  fit: BoxFit.fitHeight,
                                                  image: NetworkImage(image),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(child: Text('No Images added')),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HeadingTitle(title: 'Personal Info'),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('Current Address  :  '),
                          Text(widget.user.currentLocation)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Date of Birth:  '),
                          Text(widget.user.dob)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingTitle(title: 'Career'),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text('Occupation  :  '),
                          Text(widget.user.occupation)
                        ],
                      ),
                      Row(
                        children: [
                          Text('Qualification  :  '),
                          Text(widget.user.education)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingTitle(title: 'Family Background'),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text('Village  :  '),
                          Text(widget.user.nativeVillage)
                        ],
                      ),
                      Row(
                        children: [
                          Text('Guardian Name  :  '),
                          Text(widget.user.guardianName)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Guardian Number  :  '),
                          Text(widget.user.guardianNumber)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendFriendRequest() {
    final friendRequestService = FriendRequestService();
    final currentUser = ref.read(userProvider);

    if (currentUser != null) {
      try {
        friendRequestService.sendFriendRequest(
            currentUser.uid, widget.user.uid);
        setState(() {
          friendRequestSent = true;
        });
      } catch (e) {
        print('Error sending friend request: $e');
      }
    }
  }

  void _removeFriendRequest() {
    final friendRequestService = FriendRequestService();
    final currentUser = ref.read(userProvider);

    if (currentUser != null) {
      try {
        friendRequestService.removeFriendRequest(
            currentUser.uid, widget.user.uid);
        setState(() {
          friendRequestSent = false;
        });
      } catch (e) {
        print('Error removing friend request: $e');
        // Handle error if needed
      }
    }
  }

  void _unfriendAction() {
    final friendshipService = FriendRequestService();

    if (currentUser != null) {
      try {
        friendshipService.removeFriend(currentUser!.uid, widget.user.uid);
        setState(() {
          isFriend = false;
        });
      } catch (e) {
        print('Error unfriending user: $e');
        // Handle error if needed
      }
    }
  }

  Future<void> _showImageDialog(String imageUrl, context) async {
    return showDialog(
      context: context,
      builder: (
        BuildContext context,
      ) {
        return AlertDialog(
          backgroundColor: Colors.white70,
          elevation: 5,
          shadowColor: Colors.black,
          title: Text(
            widget.user.displayName,
            style: myTextStylefontsize20BGCOLOR,
          ),
          content: ClipRect(
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: NetworkImage(imageUrl),
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: myTextStylefontsize14Black,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent[100],
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
