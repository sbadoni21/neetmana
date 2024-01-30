import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';
import 'package:matrimonial/providers/user_state_notifier.dart';
import 'package:matrimonial/screens/homepage.dart';
import 'package:matrimonial/screens/splashscreen.dart';
import 'package:matrimonial/utils/static.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final logger = Logger(
    printer: PrettyPrinter(),
  );
  try {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBsvFtgaTqSlpYE0xt5wkc52tG6UZiSgzw",
            authDomain: "matrimonailapp.firebaseapp.com",
            projectId: "matrimonailapp",
            storageBucket: "matrimonailapp.appspot.com",
            messagingSenderId: "17511096143",
            appId: "1:17511096143:web:7a5690a0f27d1215012f3a",
            measurementId: "G-6J8Q73Y744"));
    logger.i("Firebase initialized successfully");

    runApp(ProviderScope(child: MyApp()));
  } catch (e) {
    logger.e("Firebase initialization error: $e");
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(
      userStateNotifierProvider,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matrimonail',
      theme: ThemeData(
        primaryColor: bgColor,
      ),
      navigatorKey: navigatorKey,
      home: userState == null ? SplashScreen() : HomePage(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  ErrorApp(this.errorMessage);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      home: Scaffold(
        body: Center(
          child: Text(errorMessage),
        ),
      ),
    );
  }
}
