import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageProvider = Provider<ImageServices>((ref) {
  return ImageServices();
});

class ImageServices extends ChangeNotifier {
  File? _userImage;

  File? get userImage => _userImage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String userPhotoURL = "";
  Future<List<String>> getUserImages(String currentUserId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();

      final List<dynamic>? myPhotos =
          documentSnapshot['myImages'] as List<dynamic>?;

      if (myPhotos != null) {
        List<String> imageUrls =
            myPhotos.map((dynamic url) => url.toString()).toList();
        return imageUrls;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Error fetching user images: $e");
    }
  }

  Future<void> removeImage(String currentUserId, String imageUrl) async {
    try {
      DocumentReference userRef =
          _firestore.collection('users').doc(currentUserId);
      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic>? myPhotos = userSnapshot['myImages'] as List<dynamic>?;

      if (myPhotos != null) {
        myPhotos.remove(imageUrl);
        await userRef.update({'myImages': myPhotos});
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Error removing user image: $e");
    }
  }

  void setImage(File image, String currentUserId) async {
    _userImage = image;
    print(_userImage);

    final Reference userStorageReference = _storage.ref().child(
        'user_images/${currentUserId}/${DateTime.now().millisecondsSinceEpoch}_user.png');
    print(userStorageReference);
    final UploadTask userUploadTask = userStorageReference.putFile(_userImage!);
    await userUploadTask.whenComplete(() async {
      userPhotoURL = await userStorageReference.getDownloadURL();
      print(userPhotoURL);
    });
    await addImage(currentUserId, userPhotoURL);
  }

  Future<void> addImage(String currentUserId, String imageUrl) async {
    try {
      DocumentReference userRef =
          _firestore.collection('users').doc(currentUserId);
      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic>? myPhotos = userSnapshot['myImages'] as List<dynamic>?;

      if (myPhotos != null) {
        myPhotos.add(imageUrl);
        await userRef.update({'myImages': myPhotos});
        notifyListeners();
      } else {
        await userRef.set({
          'myImages': [imageUrl]
        }, SetOptions(merge: true));
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Error adding user image: $e");
    }
  }
}
