import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/home_page.dart';
import 'package:test_app/login_page.dart';
import 'package:test_app/provider/auth_provider.dart';
import 'package:test_app/provider/theme_provider.dart';
import 'package:test_app/splash_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers:  [
      ChangeNotifierProvider(create: (_)=>ThemeProvider())  ,
          ChangeNotifierProvider(create: (_)=>AuthProvider())
        ],
      child: Consumer2< ThemeProvider,AuthProvider>(
        builder: (context,themeProvider,authProvider,child){
    return MaterialApp(
       debugShowCheckedModeBanner: false,
        title: 'Test_App',

      theme: themeProvider.currentTheme,
      home: SplashScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
      },

       );
      },
     ),
    );
  }
}


