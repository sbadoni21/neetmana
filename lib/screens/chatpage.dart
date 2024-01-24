import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrimonial/models/user_model.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/image_fullscreen_page.dart';
import 'package:matrimonial/services/user_service/chat_service.dart';
import 'package:matrimonial/widget/chatbubble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final userProvider = Provider<User?>((ref) {
  return ref.watch(userStateNotifierProvider);
});

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.otherUser});

  final User otherUser;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  File? imageFile;
  ImagePicker _picker = ImagePicker();
  bool isImagePickerActive = false;

  void sendMessage() async {
    final currentUser = ref.watch(userProvider);

    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.otherUser.uid, currentUser!.uid,
          _messageController.text, 'Text');
      _messageController.clear();
    }
  }

  Future getImage() async {
    final ImagePicker _picker = ImagePicker();
    if (!isImagePickerActive) {
      isImagePickerActive = true;
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      isImagePickerActive = false;
      if (pickedImage != null) {
        imageFile = File(pickedImage.path);
        uploadImage();
      }
    }
  }

  Future getImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    if (!isImagePickerActive) {
      isImagePickerActive = true;
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.camera);
      isImagePickerActive = false;
      if (pickedImage != null) {
        imageFile = File(pickedImage.path);
        uploadImage();
      }
    }
  }

  Future requestCameraPermission() async {
    final permissions = <Permission>[
      Permission.camera,
      Permission.storage,
    ];
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.storage]!.isGranted) {
      getImageFromCamera();
    } else {
      return;
    }
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    var ref =
        FirebaseStorage.instance.ref().child('images').child('$fileName.jpg');
    var uploadTask = await ref.putFile(imageFile!);
    String ImageUrl = await uploadTask.ref.getDownloadURL();
    sendImage(ImageUrl);
  }

  Future sendImage(String imageUrl) async {
    final currentUser = ref.watch(userProvider);

    await _chatService.sendMessage(
        widget.otherUser.uid, currentUser!.uid, imageUrl, 'Image');
  }

  String? displayName;
  String? profilePhoto;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.white,
                ],
                stops: const [0.0, 1],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    )),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Center(
                    child: CircleAvatar(
                      backgroundImage: widget.otherUser.photoURL != null
                          ? NetworkImage(widget.otherUser.photoURL!)
                              as ImageProvider // Cast to ImageProvider
                          : AssetImage(
                              'assets/image6.png'), // Use a placeholder image
                      radius: 20,
                      // Adjust the size as needed
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.otherUser.displayName != null
                          ? widget.otherUser.displayName as String
                          : "Username",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 15, 33, 47),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final currentUser = ref.watch(userProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.attach_file,
                      color: Colors.blueAccent,
                    ),
                  ),

                  hintStyle:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
                controller: _messageController,
                obscureText: false,
                style:
                    TextStyle(color: Colors.black), // Set text color to black
              ),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => getImage(),
                  icon: Icon(
                    Icons.photo,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: () => requestCameraPermission(),
                  icon: Icon(
                    Icons.photo_camera,
                    color: Colors.blueAccent,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(50), // Define the border radius
                    color: Colors.blue, // Set the background color
                  ),
                  child: IconButton(
                    onPressed: () async {
                      sendMessage();
                      var data = {
                        'to': widget.otherUser.deviceToken,
                        'priority': 'high',
                        'notification': {
                          'title': 'Niti Mana App',
                          'body':
                              "New message from " + currentUser!.displayName,
                        },
                        'data': {
                          'type': "Chat",
                        }
                      };
                      await http.post(
                          Uri.parse('https://fcm.googleapis.com/fcm/send'),
                          body: jsonEncode(data),
                          headers: {
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization':
                                'key=AAAANcq0PWM:APA91bGcMj1zySNAMfzj-tUSslTU1q5wSYMA967ndBM0Z_j0LoVagvzzk2nv-dwavXOtJ-B-uT4jUmNKfWyi-oV2Q5x9IhODo8wjWBbGx3mLuumEdkK5xEF1qxB8xA4gags2IZP5qKnN'
                          });
                    },
                    icon: const Icon(
                      Icons.send_sharp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> data) {
    final currentUser = ref.watch(userProvider);

    var alignment = (data['senderId'] == currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    if (data['type'] == 'Text') {
      return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: (data['senderId'] == currentUser.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: (data['senderId'] == currentUser.uid)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              ChatBubble(
                  message: data['message'],
                  seen: data['seen'],
                  timestamp: data['timestamp']),
            ],
          ),
        ),
      );
    } else if (data['type'] == 'Image') {
      return Container(
        alignment: alignment,
        // Expand horizontally
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: (data['senderId'] == currentUser.uid)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: (data['senderId'] == currentUser.uid)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageEnlargedView(imageUrl: data['message']),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue),
                  child: Image.network(
                    data['message'],
                    height: 350,
                    width: 350,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
    //  else if (data['type'] == 'pdf') {
    //   return Container(
    //     alignment: alignment,
    //     child: Padding(
    //       padding: const EdgeInsets.all(12.0),
    //       child: Column(
    //         crossAxisAlignment:
    //             (data['senderId'] == _firebaseAuth.currentUser!.uid)
    //                 ? CrossAxisAlignment.end
    //                 : CrossAxisAlignment.start,
    //         mainAxisAlignment:
    //             (data['senderId'] == _firebaseAuth.currentUser!.uid)
    //                 ? MainAxisAlignment.end
    //                 : MainAxisAlignment.start,
    //         children: [
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) =>
    //                       SfPdfViewer.network(data['message']),
    //                 ),
    //               );
    //             },
    //             child: Text("pdf"),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    else {
      return SnackBar(content: Text('ERROR'));
    }
  }

  Widget _buildMessageList() {
    final currentUser = ref.watch(userProvider);

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
        currentUser!.uid,
        widget.otherUser.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error');
        } else {
          List<Map<String, dynamic>> messages = [];

          DateTime? currentDate;
          for (var doc in snapshot.data!.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            DateTime? messageDate = (data['timestamp'] as Timestamp?)?.toDate();

            if (messageDate != null) {
              if (currentDate == null || !isSameDay(currentDate, messageDate)) {
                messages.add({'isDivider': true, 'date': messageDate});
                currentDate = messageDate;
              }

              messages.add({'isDivider': false, 'message': data});
            }
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              if (messages[index]['isDivider']) {
                // Display the date divider
                DateTime date = messages[index]['date'];
                String formattedDate =
                    DateFormat.yMMMd().format(date); // Format the date
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(2, 84, 152, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      formattedDate,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                );
              } else {
                // Display the message
                return _buildMessageItem(messages[index]['message']);
              }
            },
          );
        }
      },
    );
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
