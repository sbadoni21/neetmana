import 'package:flutter/material.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/screens/otherUser_detailpage.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/bubble.dart';

class SavedPreferenceTiles extends StatefulWidget {
  final User user;

  SavedPreferenceTiles({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _SavedPreferenceTilesState createState() => _SavedPreferenceTilesState();
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

class _SavedPreferenceTilesState extends State<SavedPreferenceTiles> {
  bool showAdditionalContent = false;

  @override
  Widget build(BuildContext context) {
    String ageString = calculateAgeString(widget.user.dob);
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          showAdditionalContent = !showAdditionalContent;
        });
      },
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtherUserProfilePage(user: widget.user)));
      },
      child: SizedBox(
        width: 165,
        height: showAdditionalContent ? 330 : 330,
        child: Stack(
          children: [
            Container(
              height: 154,
              width: 154,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50)),
                image: DecorationImage(
                  image: widget.user.photoURL.isNotEmpty
                      ? NetworkImage(widget.user.photoURL)
                      : AssetImage('assets/images/placeholder_image.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                top: 160,
                left: 10,
                child: Text(
                  widget.user.displayName,
                  style: myTextStylefontsize14Black,
                )),
            Positioned(
                top: 185,
                left: 10,
                child: Bubble(
                  text: '${ageString} years',
                )),
            Positioned(
                top: 215,
                left: 10,
                child: Bubble(
                  text: '${widget.user.currentLocation}',
                )),
            // if (showAdditionalContent)
            //   Positioned(
            //     left: 10,
            //     top: 245,
            //     child: AnimatedContainer(
            //       transformAlignment: Alignment.bottomCenter,
            //       alignment: Alignment.topLeft,
            //       duration: Duration(seconds: 1),
            //       height: 80,
            //       width: 150,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.only(
            //           bottomLeft: Radius.circular(10),
            //         ),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.end,
            //         children: [
            //           Bubble(
            //             text: '${widget.user.nativeVillage}',
            //           ),
            //           SizedBox(height: 4),
            //         ],
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
