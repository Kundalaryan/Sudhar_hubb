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
          FutureBuilder<String?>(
            future: authProvider.getPostUserId(postUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return SizedBox();
              }

              final postUserId = snapshot.data;
              final currentUserId = authProvider.user?.uid;

              if (postUserId == currentUserId) {
                return IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await authProvider.deletePost(postUrl);
                    Navigator.pop(context);
                  },
                );
              } else {
                return SizedBox();
              }
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
