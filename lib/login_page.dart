import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:test_app/forget_password.dart';
import 'package:test_app/provider/auth_provider.dart';
import 'package:test_app/signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Container (
        margin: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 50),
              _header(context),
              const SizedBox(height: 50),
              _inputField(context),
              const SizedBox(height: 60),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }
  _header(context){
    return  Center(
      child:  Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          Text('सुधारHub',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize:30),
            ),
          )
        ],
      ),
    );
  }
  _inputField(context){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(
                  borderRadius:BorderRadius.circular(18),
                  borderSide: BorderSide.none
              ),
              fillColor: Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
              hintText: "Password",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none
              ),
              fillColor: Colors.grey.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: GestureDetector(
                onTap: (){
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
              )
          ),
          obscureText: _obscureText,
        ),
        const SizedBox(height:5),
        Align(
          alignment: Alignment.centerRight,
          child:TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPassword()));
              },
              child:
              const Text("Forgot password?",
                  style: TextStyle(color: Colors.black,),
                  textAlign: TextAlign.left
              )
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:  (){
            Provider.of<AuthProvider>(context, listen: false).login(
              context,
              _emailController.text,
              _passwordController.text,
            );
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.black,
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.black,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: TextButton(
            onPressed: (){
              Provider.of<AuthProvider>(context, listen: false).signInWithGoogle(context);
            },

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30.0,
                  width: 30.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image:   AssetImage('assets/images/google.jpg'),
                        fit: BoxFit.cover),
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 18),

                const Text("Sign In with Google",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(" Don't have an account? "),
        TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> SignupPage()),);
            },
            child: const Text("Sign Up",
              style: TextStyle(
                  color: Colors.blue),
            )
        )
      ],
    );
  }
}

