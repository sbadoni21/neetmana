import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:matrimonial/services/notification/notificationservices.dart';
import 'package:random_string/random_string.dart';

final authenticationServicesProvider = Provider<AuthenticationServices>((ref) {
  return AuthenticationServices();
});

class AuthenticationServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error during sign-in: $e");
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? dob,
    String? nativeVillage,
    String? occupation,
    String? currentLocation,
    String? guardianName,
    String? guardianNumber,
    String? education,
    File? userImage,
  }) async {
    try {
      DocumentReference userRef = _fireStore.collection("users").doc(uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      Map<String, dynamic> updatedFields = {};

      if (displayName != null && displayName != userSnapshot['displayName']) {
        updatedFields['displayName'] = displayName;
      }

      if (phoneNumber != null && phoneNumber != userSnapshot['phoneNumber']) {
        updatedFields['phoneNumber'] = phoneNumber;
      }

      if (dob != null && dob != userSnapshot['dob']) {
        updatedFields['dob'] = dob;
      }

      if (nativeVillage != null &&
          nativeVillage != userSnapshot['nativeVillage']) {
        updatedFields['nativeVillage'] = nativeVillage;
      }

      if (occupation != null && occupation != userSnapshot['occupation']) {
        updatedFields['occupation'] = occupation;
      }

      if (currentLocation != null &&
          currentLocation != userSnapshot['currentLocation']) {
        updatedFields['currentLocation'] = currentLocation;
      }

      if (guardianName != null &&
          guardianName != userSnapshot['guardianName']) {
        updatedFields['guardianName'] = guardianName;
      }

      if (guardianNumber != null &&
          guardianNumber != userSnapshot['guardianNumber']) {
        updatedFields['guardianNumber'] = guardianNumber;
      }

      if (education != null && education != userSnapshot['education']) {
        updatedFields['education'] = education;
      }

      if (updatedFields.isNotEmpty) {
        await userRef.update(updatedFields);
      }

      if (userImage != null) {
        final Reference userStorageReference = _storage.ref().child(
            'user_images/${randomAlphaNumeric(10)}/${DateTime.now().millisecondsSinceEpoch}_user.png');
        final UploadTask userUploadTask =
            userStorageReference.putFile(userImage);
        TaskSnapshot taskSnapshot = await userUploadTask.whenComplete(() {});
        String userPhotoURL = await taskSnapshot.ref.getDownloadURL();
        updatedFields['photo'] = userPhotoURL;
        await userRef.update({'photo': userPhotoURL});
      }
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  bool isGoogleUser() {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        return user.providerData
            .any((userInfo) => userInfo.providerId == 'google.com');
      }
    } catch (e) {
      print('Error checking if user signed up with Google: $e');
    }
    return false;
  }

  Future<bool> validateOTP(String otpEntered, String otpSent) async {
    return otpEntered == otpSent;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Failed to reset password: $e');
      return false;
    }
  }

  Future<bool> _userExists(String uid) async {
    try {
      DocumentSnapshot document =
          await _fireStore.collection('users').doc(uid).get();
      return document.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      User? user = firebaseAuth.currentUser;
      if (user != null) {
        return user.uid;
      }
    } catch (e) {
      print('Failed to get current user ID: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await firebaseAuth.signOut();
  }

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
    required String education,
    required String nativeVillage,
    required String phoneNumber,
    File? userImage,
    File? authImage,
  }) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
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
          'photo': userPhotoURL ?? "none",
          'authphoto': authPhotoURL ?? "none",
          'deviceToken': deviceToken,
          'gender': gender,
          'currentLocation': currentLocation,
          'dob': dob,
          'role': role,
          'education': education,
          'nativeVillage': nativeVillage,
          'occupation': occupation,
          'guardianName': guardianName,
          'guardianNumber': guardianNumber,
          'phoneNumber': phoneNumber,
          'myImages': [],
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
