import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_app/home_page.dart';
import 'package:test_app/login_page.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signup(BuildContext context, String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(username);

      // Save the username to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'profilePicture': '',
      });

      notifyListeners();

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> login(BuildContext context, String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Save the username and profile picture URL to Firestore if it's a new user
      if (userCredential.additionalUserInfo!.isNewUser) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': googleUser.displayName,
          'email': googleUser.email,
          'profilePicture': googleUser.photoUrl,
        });
      }

      notifyListeners();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getProfileDetails() async {
    if (_user != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<String?> getProfilePictureUrl() async {
    if (_user != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      return userDoc['profilePicture'];
    }
    return null;
  }

  // New method to fetch user posts
  Future<List<String>> getUserPosts() async {
    try {
      // Replace 'posts' with the name of your Firestore collection for posts
      final userPostsCollection = FirebaseFirestore.instance.collection('posts');

      if (_user != null) {
        // Fetch posts for the current user
        final querySnapshot = await userPostsCollection
            .where('userId', isEqualTo: _user!.uid)
            .get();

        // Extract image URLs from the documents
        List<String> postUrls = querySnapshot.docs
            .map((doc) => doc['imageUrl'] as String)
            .toList();

        return postUrls;
      }
      return [];
    } catch (e) {
      // Handle any errors that occur during the fetch
      print('Error fetching user posts: $e');
      return [];
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    if (_user != null) {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
        'profilePicture': imageUrl,
      });
      notifyListeners();
    }
  }

  // New method to delete a post
  Future<void> deletePost(String postUrl) async {
    try {
      // Find the post document by its image URL and delete it
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('imageUrl', isEqualTo: postUrl)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors that occur during the deletion
      print('Error deleting post: $e');
    }
  }
}
