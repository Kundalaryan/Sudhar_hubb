import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/provider/auth_provider.dart';

class PostDetailPage extends StatelessWidget {
  final String postUrl;

  PostDetailPage({required this.postUrl});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await authProvider.deletePost(postUrl);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Image.network(postUrl),
      ),
    );
  }
}
