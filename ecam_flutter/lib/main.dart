import 'package:ecam_flutter/providers/user_provider.dart';
import 'package:ecam_flutter/responsive/mobile_screen_layout.dart';
import 'package:ecam_flutter/responsive/web_screen_layout.dart';
import 'package:ecam_flutter/responsive/responsive_layout_screen.dart';
import 'package:ecam_flutter/screens/login_screen.dart';
import 'package:ecam_flutter/screens/signup_screen.dart';
import 'package:ecam_flutter/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'responsive/web_screen_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'daveApp',
    options: const FirebaseOptions(
      apiKey: "AIzaSyAXL7AmPHtBO7qapJhWBmNU6jHR8AqwrFQ",
      appId: "1:157420175194:web:77f81ad1cc08700018bd63",
      messagingSenderId: "157420175194",
      projectId: "ecam-flutter",
      storageBucket: "ecam-flutter.appspot.com",

      //authDomain: "ecam-flutter.firebaseapp.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ecam flutter',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                // means user has authentificated
                if (snapshot.hasData) {
                  return const ResponsiveLayout(
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout(),
                  );
                }
                //
                else if (snapshot.hasError) {
                  return const Center(
                    //child: Text('${snapshot.error}'),
                    child: Text('BIP'),
                  );
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: primaryColor,
                ));
              }
              return const LoginScreen();
            }),
      ),
    );
  }
}
