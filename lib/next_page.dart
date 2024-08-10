import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:test_app/provider/auth_provider.dart';

class NextScreen extends StatefulWidget {
  final File imageFile;

  NextScreen(this.imageFile);

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  Position? _position;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Post",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => _uploadPost(authProvider),
            child: Text("Share"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 70,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Image.file(widget.imageFile).image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 280,
                    height: 60,
                    child: TextField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption ...',
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 480,
                height: 130,
                child: TextField(
                  controller: _locationController,
                  readOnly: true,
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await getLocation();
                    setState(() {
                      isLoading = false;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Add Location",
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.grey.withOpacity(0.1),
                    filled: true,
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await getLocation();
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: const Icon(Icons.add_location_alt_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _position = position;
      _locationController.text =
      "Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}";
    });
  }

  Future<void> _uploadPost(AuthProvider authProvider) async {
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a location')),
      );
      return;
    }

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    // Show the loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading...'),
            ],
          ),
        );
      },
    );

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await storageRef.putFile(widget.imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      // Save post details to Firestore
      var username = authProvider.user?.displayName;
      var userId = authProvider.user?.uid;
      var location = '${_position!.latitude}, ${_position!.longitude}';
      var profilePicture = authProvider.user?.photoURL;

      await FirebaseFirestore.instance.collection('posts').add({
        'username': username,
        'userId': userId,
        'location': location,
        'imageUrl': downloadUrl,
        'Caption': _captionController.text,
        'profilePicture': profilePicture,
        'timestamp': Timestamp.now(),
      });

      Navigator.pop(context); // Dismiss the loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully!')),
      );

      Navigator.pop(context); // Navigate back to the previous screen
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post: $e')),
      );
    }
  }

}
