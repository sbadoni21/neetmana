class User {
  final String deviceToken;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String photoURL;
  final String authImage;
  final String status;
  final String dob;
  final String nativeVillage;
  final String role;
  final String gender;
  final String uid;
  final String currentLocation;
  final String guardianName;
  final String guardianNumber;
  final String occupation;
  final List? savedUsers;

  User(
      {required this.deviceToken,
      required this.displayName,
      required this.email,
      required this.phoneNumber,
      required this.authImage,
      required this.photoURL,
      required this.status,
      required this.dob,
      required this.uid,
      required this.role,
      required this.nativeVillage,
      required this.gender,
      required this.currentLocation,
      required this.guardianName,
      required this.occupation,
      this.savedUsers,
      required this.guardianNumber});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        deviceToken: map['deviceToken'] ?? '',
        displayName: map['displayName'] ?? '',
        email: map['email'] ?? '',
        role:map['role']?? '',
        authImage: map['authphoto'],
        phoneNumber: map['phoneNumber'] ?? '',
        photoURL: map['profilephoto'] ?? '',
        status: map['status'] ?? '',
        gender: map['gender'] ?? '',
        uid: map['uid'] ?? '',
        currentLocation: map['currentLocation'] ?? '',
        dob: map['dob'] ?? "",
        guardianName: map['guardianName'],
        guardianNumber: map['guardianNumber'],
        savedUsers: List<String>.from(map['savedUsers'] ?? []),
        occupation: map['occupation'],
        nativeVillage: map['nativeVillage'] ?? "");
  }
}

class ChatMessage {
  final String senderId;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}
