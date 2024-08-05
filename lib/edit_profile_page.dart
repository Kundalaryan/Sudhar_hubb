import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  File? _profileImage;
  String _profileImageUrl = ''; // Store the URL of the existing profile image
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _profileImageUrl = userData['profilePicture'] ?? '';
      });

      // Load the existing profile image from the URL
      if (_profileImageUrl.isNotEmpty) {
        _loadProfileImage();
      }
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      final image = await _storage.refFromURL(_profileImageUrl).getData();
      if (image != null) {
        setState(() {
          _profileImage = File.fromRawPath(image);
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Show saving dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevents closing the dialog by tapping outside
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Saving profile...'),
              ],
            ),
          );
        },
      );

      try {
        String profilePicUrl = _profileImageUrl; // Use existing image URL by default
        if (_profileImage != null) {
          final ref = _storage.ref().child('profile_pics/${user.uid}');
          await ref.putFile(_profileImage!);
          profilePicUrl = await ref.getDownloadURL();
        }
        await _firestore.collection('users').doc(user.uid).update({
          'username': _usernameController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'profilePicture': profilePicUrl,
        });

        // Dismiss the saving dialog
        Navigator.pop(context);

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Profile Updated'),
              content: Text('Your profile has been updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the success dialog
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Dismiss the saving dialog if an error occurs
        Navigator.pop(context);

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while updating the profile. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the error dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _updateProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  _profileImage != null
                      ? CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(_profileImage!),
                  )
                      : _profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_profileImageUrl),
                  )
                      : CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        onPressed: () => _showImageSourceActionSheet(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
              readOnly: true,
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
