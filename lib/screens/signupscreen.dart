import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matrimonial/screens/homepage.dart';
import 'package:matrimonial/screens/loginscreen.dart';
import 'package:matrimonial/services/auth/signupservices.dart';
import 'package:matrimonial/utils/static.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController =
      TextEditingController();
  File? _userImage;
  File? _authImage;
  final TextEditingController genderController = TextEditingController();
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController guardianNumberController =
      TextEditingController();
  final TextEditingController roleController = TextEditingController();

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController nativeVillageController = TextEditingController();
  final GlobalKey<FormState> _firstPageKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _secondPageKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _thirdPageKey = GlobalKey<FormState>();
  int _currentPage = 1;
  String? _selectedDate;

  final ImagePicker _imagePicker = ImagePicker();

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

  Future<void> _selectAuthImage() async {
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
        print('Permission denied by the user.');
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

  Future<void> _submitFirstPage() async {
    if (_firstPageKey.currentState?.validate() ?? false) {
      setState(() {
        _currentPage = 2;
      });
    }
  }

  Future<void> _submitSecondPage() async {
    if (_secondPageKey.currentState?.validate() ?? false) {
      setState(() {
        _currentPage = 3;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_thirdPageKey.currentState?.validate() ?? false) {
      User? user = await signup_service().registerUser(
          name: fullNameController.text,
          email: emailController.text,
          password: passwordController.text,
          currentLocation: locationController.text,
          gender: genderController.text,
          role: roleController.text,
          guardianName: guardianNameController.text,
          guardianNumber: guardianNumberController.text,
          occupation: occupationController.text,
          dob: dobController.text,
          nativeVillage: nativeVillageController.text,
          userImage: _userImage,
          authImage: _authImage,
          phoneNumber: phoneNumberController.text);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error has been encountered"),
          ),
        );
      }

      fullNameController.clear();
      locationController.clear();
      emailController.clear();
      passwordController.clear();
      retypePasswordController.clear();
      genderController.clear();
      guardianNameController.clear();
      guardianNumberController.clear();
      occupationController.clear();
      dobController.clear();
      nativeVillageController.clear();
      _userImage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _currentPage == 1
                  ? _firstPageKey
                  : _currentPage == 2
                      ? _secondPageKey
                      : _thirdPageKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/placeholder_image.png",
                        fit: BoxFit.contain,
                        height: 230,
                        width: 180,
                      ),
                      const Center(
                        child: Text(
                          "matrimonal",
                          style: TextStyle(
                            color: bgColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    height: 16,
                  ),
                  _currentPage == 1
                      ? _buildFirstPageFields()
                      : _currentPage == 2
                          ? _buildSecondPageFields()
                          : _buildThirdPageFields(),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _currentPage == 1
                        ? _submitFirstPage
                        : _currentPage == 2
                            ? _submitSecondPage
                            : _submitForm,
                    child: Text(
                      _currentPage == 1
                          ? "Next"
                          : _currentPage == 2
                              ? "Next"
                              : "Submit",
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      backgroundColor: bgColor, // Background color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 45.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      backgroundColor: Colors.white, // Text color
                      side: BorderSide(color: bgColor), // Border color
                    ),
                    child: Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: const Text('Sign In')),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPageFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTextField(
          controller: fullNameController,
          labelText: 'Full Name',
          hintText: 'Enter your full name',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildGenderDropdown(),
        const SizedBox(height: 16),
        _buildRoleForDropdown(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: locationController,
          labelText: 'Current Location',
          hintText: 'Enter your location',
          icon: Icons.location_city,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: occupationController,
          labelText: 'Occupation',
          hintText: 'Enter your occupation',
          icon: Icons.work,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.blue,
              ),
            ),
            child: _userImage != null
                ? Image.file(
                    _userImage!,
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.blue),
                      Text('Select Image'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPageFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
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
                _selectedDate = DateFormat('dd/MM/yyyy').format(selectedDate);
                dobController.text = _selectedDate!;
              });
            }
          },
          decoration: InputDecoration(
            labelText: 'Date of Birth (dd/mm/yyyy)',
            hintText: 'Enter your date of birth',
            prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
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
        const SizedBox(height: 16),
        _buildTextField(
          controller: guardianNameController,
          labelText: 'Guardian Name',
          hintText: 'Enter your guardian name',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          controller: guardianNumberController,
          labelText: 'Guardian Number',
          hintText: 'Enter your guardian number',
          icon: Icons.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: nativeVillageController,
          labelText: 'Native Village',
          hintText: 'Enter your native village',
          icon: Icons.location_city,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectAuthImage,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.blue,
              ),
            ),
            child: _userImage != null
                ? Image.file(
                    _userImage!,
                    fit: BoxFit.cover,
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.blue),
                      Text('Select Identification Image  '),
                      Text('Aadhar card, Pan Card ,Voter Id etc')
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildThirdPageFields() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildNumberField(
          controller: phoneNumberController,
          labelText: 'Phone No.',
          hintText: 'Enter your contact number',
          icon: Icons.email,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: emailController,
          labelText: 'Email',
          hintText: 'Enter your email',
          icon: Icons.email,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: passwordController,
          labelText: 'Password',
          hintText: 'Enter your password',
          icon: Icons.password,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: retypePasswordController,
          labelText: 'Retype Password',
          hintText: 'Retype your password',
          icon: Icons.password,
          obscureText: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        } else if (labelText == 'Email' &&
            !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                .hasMatch(value)) {
          return 'Please enter a valid email address';
        } else if (labelText == 'Password' && value.length < 6) {
          return 'Password must be at least 6 characters';
        } else if (labelText == 'Retype Password' &&
            value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      borderRadius: BorderRadius.circular(25),
      value: genderController.text.isNotEmpty ? genderController.text : null,
      onChanged: (String? newValue) {
        setState(() {
          genderController.text = newValue ?? '';
        });
      },
      items: ['Male', 'Female'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.people, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select gender';
        }
        return null;
      },
    );
  }

  Widget _buildRoleForDropdown() {
    return DropdownButtonFormField<String>(
      borderRadius: BorderRadius.circular(25),
      value: genderController.text.isNotEmpty ? genderController.text : null,
      onChanged: (String? newValue) {
        setState(() {
          genderController.text = newValue ?? '';
        });
      },
      items: ['Self', 'Someone'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Looking for',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.people, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select the field';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        } else if (value.length != 10 || int.tryParse(value) == null) {
          return 'Please enter a valid 10-digit number';
        }
        return null;
      },
    );
  }
}
