import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/next_page.dart';




class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _imageFile;
  ImagePicker _imagePicker = ImagePicker();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: Text("Add Post",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              if (_imageFile !=null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NextScreen(_imageFile!),
                  ),
                );
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please select an image"),
                  ),
                );
              }
            },
            child: Text("Next",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: 400,
              width: 300,
              child: _imageFile != null
                  ? Image.file(_imageFile!)
                  : Icon(Icons.image,size: 50,),
            ),
            SizedBox(height: 15),
            MaterialButton(
              onPressed: () {
                _getImageFromGallery();
              },
              color: Colors.grey..withOpacity(0.3),
              child: Text("Take from gallery",
                style: TextStyle(
                  color: Colors.black
                ),
              ),
            ),
            SizedBox(height: 15),
            MaterialButton(
              onPressed: () {
                _getImageFromCamera();
              },
              color: Colors.grey,
              child: Text("Take from camera",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  _getImageFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        _imageFile = null;
      }
    });
  }

  _getImageFromCamera() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        _imageFile = null;
      }
    });
  }
}