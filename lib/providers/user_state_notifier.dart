import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matrimonial/models/user_model.dart';

import '../services/auth/authentication.dart';

final authenticationServicesProvider = Provider<AuthenticationServices>((ref) {
  return AuthenticationServices();
});

class UserStateNotifier extends StateNotifier<User?> {
  final Ref ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserStateNotifier(this.ref) : super(null) {
    _initUser();
  }
  Future<void> _initUser() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await fetchUserData(firebaseUser.uid);
    }
  }

  Future<User?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists && snapshot.data() != null) {
        state = User.fromMap(snapshot.data()!);
        return state;
      } else {
        state = null;
      }
    } catch (e) {
      state = null;
    }
  }

  Future<void> updateUserData(User updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .set(updatedUser.toMap(), SetOptions(merge: true));

      state = updatedUser;
    } catch (e) {}
  }

  Future<User?> signIn(String email, String password) async {
    try {
      var firebaseUser = await ref
          .read(authenticationServicesProvider)
          .signIn(email, password);
      if (firebaseUser != null) {
        return await fetchUserData(firebaseUser.uid);
      } else {
        state = null;
      }
    } catch (e) {
      state = null; // Handle exceptions
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(authenticationServicesProvider).signOut();
      state = null;
    } catch (e) {
      // Handle exceptions
    }
  }

  Future<User?> signInWithEmail({
    required String name,
    required String email,
    required String password,
    required String currentLocation,
    required String gender,
    required String role,
    required String guardianName,
    required String guardianNumber,
    required String occupation,
    required String education,
    required String dob,
    required String nativeVillage,
    required String phoneNumber,
    File? userImage,
    File? authImage,
  }) async {
    try {
      var firebaseUser = await ref
          .read(authenticationServicesProvider)
          .registerUser(
              currentLocation: currentLocation,
              dob: dob,
              email: email,
              gender: gender,
              guardianName: guardianName,
              guardianNumber: guardianNumber,
              name: name,
              education: education,
              nativeVillage: nativeVillage,
              occupation: occupation,
              password: password,
              phoneNumber: phoneNumber,
              role: role,
              authImage: authImage,
              userImage: userImage);
      if (firebaseUser != null) {
        User? user = await fetchUserData(firebaseUser.uid);
        print(
            'helllpppppp sdadsasdasdadsasdadasdadasd    ${firebaseUser.uid}   ');
        return user;
      } else {
        state = null;
        return null;
      }
    } catch (e) {
      state = null;
      return null;
    }
  }
Future<User?> profileEditingScreen({
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
    // Update the user profile
    await ref.read(authenticationServicesProvider).updateUserProfile(
      uid: uid,
      displayName: displayName,
      phoneNumber: phoneNumber,
      dob: dob,
      nativeVillage: nativeVillage,
      occupation: occupation,
      currentLocation: currentLocation,
      guardianName: guardianName,
      guardianNumber: guardianNumber,
      education: education,
      userImage: userImage,
    );

    User? user = await fetchUserData(uid);

    if (user != null) {
      print('User profile updated successfully: ${user.displayName}');
      return user;
    } else {
      print('Failed to fetch updated user data.');
      return null;
    }
  } catch (e) {
    print('Error updating user profile: $e');
    return null;
  }
}

}

final userStateNotifierProvider =
    StateNotifierProvider<UserStateNotifier, User?>(
  (ref) => UserStateNotifier(ref),
);

extension on User {
  Map<String, dynamic> toMap() {
    return {
      'deviceToken': deviceToken,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photo': photoURL,
      'status': status,
      'gender': gender,
      'uid': uid,
      'currentLocation': currentLocation,
      'dob': dob,
      'nativeVillage': nativeVillage,
      'authphoto': authImage,
      'guardianName': guardianName,
      'guardianNumber': guardianNumber,
      'occupation': occupation,
      'role': role,
      'myImages': userImages
    };
  }
}
