import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/profile_page.dart';
import 'package:matrimonial/services/profile/profileservices.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController nativeVillageController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController currentLocationController =
      TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController guardianNumberController =
      TextEditingController();
  final TextEditingController educationController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _userImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    displayNameController.text = user?.displayName ?? '';
    phoneNumberController.text = user?.phoneNumber ?? '';
    dobController.text = user?.dob ?? '';
    nativeVillageController.text = user?.nativeVillage ?? '';
    occupationController.text = user?.occupation ?? '';
    currentLocationController.text = user?.currentLocation ?? '';
    guardianNameController.text = user?.guardianName ?? '';
    guardianNumberController.text = user?.guardianNumber ?? '';
    educationController.text = user?.education ?? '';
  }

  Future<void> _selectImage() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      if (await Permission.storage.request().isGranted) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          setState(() {
            _userImage = File(pickedFile.path);
          });
        }
      } else {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          setState(() {
            _userImage = File(pickedFile.path);
          });
        }
      }
    } else {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _userImage = File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = ref.read(userProvider);
    String _selectedDate = user!.dob;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          ElevatedButton(
            onPressed: () {
              _saveChanges();
            },
            child: Text('Save Changes'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(
              controller: displayNameController,
              labelText: 'Display Name',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: phoneNumberController,
              labelText: 'Phone Number',
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: dobController,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _selectedDate =
                        DateFormat('dd/MM/yyyy').format(selectedDate);
                    dobController.text = _selectedDate;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Date of Birth (dd/mm/yyyy)',
                hintText: 'Enter your date of birth',
                prefixIcon:
                    const Icon(Icons.calendar_today, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth';
                }

                try {
                  DateFormat('dd/MM/yyyy').parseStrict(value);
                  return null;
                } catch (e) {
                  return 'Invalid date format (dd/mm/yyyy)';
                }
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: nativeVillageController,
              labelText: 'Native Village',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: occupationController,
              labelText: 'Occupation',
            ),
            SizedBox(height: 20),
            _buildImage(),
            SizedBox(height: 20),
            _buildTextField(
              controller: guardianNameController,
              labelText: 'Guardian Name',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: guardianNumberController,
              labelText: 'Guardian Number',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: guardianNumberController,
              labelText: 'Guardian Number',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: educationController,
              labelText: 'Education',
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

  Widget _buildImage() {
    return GestureDetector(
      onTap: _selectImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.blue,
          ),
        ),
        child: _userImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.file(
                  _userImage!,
                  fit: BoxFit.cover,
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'Change Profile Photo',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }

  void _saveChanges() async {
    final user = ref.read(userProvider);

    await ref.read(userStateNotifierProvider.notifier).profileEditingScreen(
        uid: user!.uid,
        displayName: displayNameController.text,
        phoneNumber: phoneNumberController.text,
        dob: dobController.text,
        nativeVillage: nativeVillageController.text,
        occupation: occupationController.text,
        userImage: _userImage,
        guardianName: guardianNameController.text,
        guardianNumber: guardianNumberController.text,
        currentLocation: currentLocationController.text,
        education: educationController.text);
    Navigator.pop(context);
  }
}
