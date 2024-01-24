import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/screens/profile_page.dart';
import 'package:matrimonial/services/profile/profileservices.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  // Add controllers for other fields you want to edit

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    displayNameController.text = user?.displayName ?? '';
    phoneNumberController.text = user?.phoneNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: displayNameController,
              labelText: 'Display Name',
            ),
            _buildTextField(
              controller: phoneNumberController,
              labelText: 'Phone Number',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  void _saveChanges() async {
    await ProfileService().updateUserProfile(
        displayName: displayNameController.text,
        phoneNumber: phoneNumberController.text);
    Navigator.pop(context);
  }
}
