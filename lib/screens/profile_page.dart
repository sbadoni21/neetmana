import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/editprofile_page.dart';
import 'package:matrimonial/screens/splashscreen.dart';
import 'package:matrimonial/services/auth/authentication.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class ProfilePage extends ConsumerStatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 150,
              backgroundImage: NetworkImage(user?.photoURL ?? ''),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),
            _buildInfoRow('Display Name', user?.displayName),
            SizedBox(height: 10),
            _buildInfoRow('Email', user?.email),
            SizedBox(height: 10),
            _buildInfoRow('Phone Number', user?.phoneNumber),
            SizedBox(height: 10),
            _buildInfoRow('Status', user?.status),
            SizedBox(height: 10),
            _buildInfoRow('Gender', user?.gender),
            SizedBox(height: 10),
            _buildInfoRow('Occupation', user?.occupation),
            SizedBox(height: 10),
            _buildInfoRow('Current Location', user?.currentLocation),
            SizedBox(height: 10),
            _buildInfoRow('Date of Birth', user?.dob),
            SizedBox(height: 10),
            _buildInfoRow('Native Village', user?.nativeVillage),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  await AuthenticationServices().signOut();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SplashScreen(),
                      ));
                },
                child: Icon(Icons.logout))
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
