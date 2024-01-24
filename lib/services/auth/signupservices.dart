import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matrimonial/services/notification/notificationservices.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class signup_service {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
    required String currentLocation,
    required String gender,
    required String role,
    required String guardianName,
    required String guardianNumber,
    required String occupation,
    required String dob,
    required String nativeVillage,
    required String phoneNumber,
    File? userImage,
    File? authImage,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final deviceToken = await NotificationService().getDeviceToken();
        String? userPhotoURL;
        String? authPhotoURL;

        if (userImage != null) {
          final Reference userStorageReference = _storage.ref().child(
              'user_images/${userCredential.user!.uid}/${DateTime.now().millisecondsSinceEpoch}_user.png');
          final UploadTask userUploadTask =
              userStorageReference.putFile(userImage);
          await userUploadTask.whenComplete(() async {
            userPhotoURL = await userStorageReference.getDownloadURL();
          });
        }

        if (authImage != null) {
          final Reference authStorageReference = _storage.ref().child(
              'auth_images/${userCredential.user!.uid}/${DateTime.now().millisecondsSinceEpoch}_auth.png');
          final UploadTask authUploadTask =
              authStorageReference.putFile(authImage);
          await authUploadTask.whenComplete(() async {
            authPhotoURL = await authStorageReference.getDownloadURL();
          });
        }

        await _fireStore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': name,
          'status': 'Online',
          'profilephoto': userPhotoURL ?? "none",
          'authphoto': authPhotoURL ?? "none",
          'deviceToken': deviceToken,
          'gender': gender,
          'currentLocation': currentLocation,
          'dob': dob,
          'nativeVillage': nativeVillage,
          'occupation': occupation,
          'guardianName': guardianName,
          'guardianNumber': guardianNumber,
          'phoneNumber': phoneNumber
        }, SetOptions(merge: true));

        return userCredential.user;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }

    return null;
  }
}
