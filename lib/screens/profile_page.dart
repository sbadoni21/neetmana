import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/splashscreen.dart';
import 'package:matrimonial/services/user_service/image_upload_service.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/heading_component.dart';
import 'package:permission_handler/permission_handler.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});
final imageServiceProvider = ChangeNotifierProvider<ImageServices>((ref) {
  return ImageServices();
});

class ProfilePage extends ConsumerStatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

final ImagePicker _imagePicker = ImagePicker();
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

Future<void> _selectImage(ref) async {
  var status = await Permission.storage.status;
  final user = ref.watch(userProvider);

  if (!status.isGranted) {
    if (await Permission.storage.request().isGranted) {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        ref
            .read((imageServiceProvider).notifier)
            .setImage(File(pickedFile.path));
      }
    } else {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        ref
            .read((imageServiceProvider.notifier))
            .setImage(File(pickedFile.path), user.uid);
      }
    }
  } else {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      ref
          .read((imageServiceProvider.notifier))
          .setImage(File(pickedFile.path), user.uid);
    }
  }
}

Future<void> _showDeleteImageDialog(
    String imageUrl, context, String userId) async {
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
          "Delete Image",
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
          TextButton(
            onPressed: () async {
              await ImageServices().removeImage(userId, imageUrl);

              Navigator.of(context).pop();
            },
            child: Text("Delete", style: myTextStylefontsize14Black),
          ),
        ],
      );
    },
  );
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final imageServices = ref.watch(imageServiceProvider);
    return Scaffold(
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              width: double.infinity,
              height: 224,
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
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(user!.photoURL),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 180,
                    top: 80,
                    child: SizedBox(
                      width: 120,
                      child: Text(
                        user.displayName,
                        style: myTextStylefontsize16white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    top: 160,
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(userStateNotifierProvider.notifier)
                              .signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SplashScreen()));
                        },
                        child: Text(
                          "SignOut",
                          style: myTextStylefontsize12bgcolor,
                        ),
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
                          user.occupation,
                          style: myTextStylefontsize14White,
                        ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        // Text(
                        //   '$ageString years',
                        //   style: myTextStylefontsize14White,
                        // ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          user.currentLocation,
                          style: myTextStylefontsize14White,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20, 0),
              child: HeadingTitle(title: 'Images'),
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: imageServices.getUserImages(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 90,
                      height: 140,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 5,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            _selectImage(ref);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 50,
                              ),
                              Text(
                                "Add ",
                                style: myTextStylefontsize12Black,
                              ),
                              Text(
                                "Image ",
                                style: myTextStylefontsize12Black,
                              ),
                            ],
                          )),
                    ),
                  );
                } else {
                  List<String> fetchedImages = snapshot.data as List<String>;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      height: 150,
                      child: fetchedImages.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fetchedImages.length,
                              itemBuilder: (context, index) {
                                String image = fetchedImages[index];
                                return index != fetchedImages.length - 1
                                    ? GestureDetector(
                                        // onTap: () {
                                        //   Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) =>
                                        //           CourseDetailPage(
                                        //               courses: course),
                                        //     ),
                                        //   );
                                        // },
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
                                                          BorderRadius.circular(
                                                              10),
                                                      image: DecorationImage(
                                                        fit: BoxFit.fitHeight,
                                                        image:
                                                            NetworkImage(image),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      _showDeleteImageDialog(
                                                          image,
                                                          context,
                                                          user.uid);
                                                    },
                                                    icon: const Icon(
                                                        Icons.close_outlined,
                                                        color: Colors.red,
                                                        fill: 1,
                                                        weight: 10),
                                                    iconSize: 20,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          GestureDetector(
                                            // onTap: () {
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           CourseDetailPage(
                                            //               courses: course),
                                            //     ),
                                            //   );
                                            // },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: SizedBox(
                                                width: 90,
                                                height: 150,
                                                child: Stack(
                                                  children: [
                                                    ClipRect(
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit
                                                                .fitHeight,
                                                            image: NetworkImage(
                                                                image),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          _showDeleteImageDialog(
                                                              image,
                                                              context,
                                                              user.uid);
                                                        },
                                                        icon: const Icon(
                                                            Icons
                                                                .close_outlined,
                                                            color: Colors.red,
                                                            fill: 1,
                                                            weight: 10),
                                                        iconSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          index < 3
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Container(
                                                    width: 90,
                                                    height: 140,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            elevation: 5,
                                                            backgroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                        onPressed: () {
                                                          _selectImage(ref);
                                                        },
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.add,
                                                              size: 50,
                                                            ),
                                                            Text(
                                                              "Add ",
                                                              style:
                                                                  myTextStylefontsize12Black,
                                                            ),
                                                            index <
                                                                    fetchedImages
                                                                            .length -
                                                                        1
                                                                ? Text(
                                                                    "Images ",
                                                                    style:
                                                                        myTextStylefontsize12Black,
                                                                  )
                                                                : Text(
                                                                    "Image ",
                                                                    style:
                                                                        myTextStylefontsize12Black,
                                                                  ),
                                                          ],
                                                        )),
                                                  ),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Container(
                                                    width: 100,
                                                    height: 140,
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            elevation: 5,
                                                            backgroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                        onPressed: () {},
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Icon(
                                                              Icons.delete,
                                                              size: 50,
                                                            ),
                                                            Text(
                                                              "Remove",
                                                              style:
                                                                  myTextStylefontsize12Black,
                                                            ),
                                                            index <
                                                                    fetchedImages
                                                                            .length -
                                                                        1
                                                                ? Text(
                                                                    "Image ",
                                                                    style:
                                                                        myTextStylefontsize12Black,
                                                                  )
                                                                : Text(
                                                                    "Image ",
                                                                    style:
                                                                        myTextStylefontsize12Black,
                                                                  ),
                                                          ],
                                                        )),
                                                  ),
                                                )
                                        ],
                                      );
                              },
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: SizedBox(
                                    height: 140,
                                    width: 140,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 5,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        onPressed: () {
                                          _selectImage(ref);
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size: 50,
                                            ),
                                            Text(
                                              "Add ",
                                              style: myTextStylefontsize12Black,
                                            ),
                                            Text(
                                              "Images ",
                                              style: myTextStylefontsize12Black,
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }
              },
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
                      const HeadingTitle(title: 'Career'),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('Occupation  :  '),
                          Text(user.occupation)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Qualification  :  '),
                          Text(user.education)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
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
                      const HeadingTitle(title: 'Family Background'),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Text('Village  :  '),
                          Text(user.nativeVillage)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Guardian Name  :  '),
                          Text(user.guardianName)
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Guardian Number  :  '),
                          Text(user.guardianNumber)
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

  Widget _buildInfoRow(String label, String? value) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blueAccent[100],
          borderRadius: BorderRadius.all(Radius.circular(10))),
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
                  color: Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
