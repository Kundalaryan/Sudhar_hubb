import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SudharHub/home_page.dart';
import 'package:SudharHub/login_page.dart';
import 'package:SudharHub/provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png', // Ensure you have the logo image in your assets
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

