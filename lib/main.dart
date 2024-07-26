import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/Screens/Notificationpage.dart';
import 'package:puzzle/Screens/submainpage.dart';
import 'package:puzzle/page/firebase_api.dart';
import 'Screens/theme_provider.dart';
import 'SlidePuzzleHomePage.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialization with Web Support
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyAU8I983MSbfdG9tTPBlH7qJeonkT8Towg",
          authDomain: "slidepuzzle1-c207e.firebaseapp.com",
          projectId: "slidepuzzle1-c207e",
          storageBucket: "slidepuzzle1-c207e.appspot.com",
          messagingSenderId: "974243331376",
          appId: "1:974243331376:web:03338a9acfebd9cb19dcf5",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    await FirebaseApi().initNotifications();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(ThemeData.light()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          home: MainPage(),
          navigatorKey: navigatorKey,
          routes: {
            '/notification_screen': (context) => Notificationpage(),
          },
        );
      },
    );
  }
}
