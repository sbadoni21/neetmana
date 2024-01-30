import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/splashscreen.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:matrimonial/widget/heading_component.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class ProfilePage extends ConsumerStatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
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

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

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
                          Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SplashScreen()));
                        },
                        child: Text(
                          "SignOut",
                          style: myTextStylefontsize12Black,
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

            // FutureBuilder(
            //         future: fetchFeaturedCollectionData(),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return const Center(child: CircularProgressIndicator());
            //           } else if (snapshot.hasError) {
            //             return Center(child: Text('Error: ${snapshot.error}'));
            //           } else {
            //             List<Course> featuredCourses =
            //                 snapshot.data as List<Course>;

            //             return SizedBox(
            //               height: 170,
            //               child: featuredCourses.isNotEmpty
            //                   ? ListView.builder(
            //                       scrollDirection: Axis.horizontal,
            //                       itemCount: featuredCourses.length,
            //                       itemBuilder: (context, index) {
            //                         Course course = featuredCourses[index];
            //                         return GestureDetector(
            //                           onTap: () {
            //                             Navigator.push(
            //                               context,
            //                               MaterialPageRoute(
            //                                 builder: (context) =>
            //                                     CourseDetailPage(
            //                                         courses: course),
            //                               ),
            //                             );
            //                           },
            //                           child: Padding(
            //                             padding: const EdgeInsets.only(
            //                                 left: 8.0, right: 8),
            //                             child: Tiles(course: course),
            //                           ),
            //                         );
            //                       },
            //                     )
            //                   : const Text("No featured courses available."),
            //             );
            //           }
            //         },
            //       ),
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
                          Text(user.occupation)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
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
                          const Text('Father Name  :  '),
                          Text(user.guardianName)
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
