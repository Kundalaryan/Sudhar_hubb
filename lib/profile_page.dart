import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/account_screen.dart';
import 'package:test_app/provider/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userDetailsFuture;
  late Future<List<String>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userDetailsFuture = authProvider.getProfileDetails();
    _userPostsFuture = authProvider.getUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          _userDetailsFuture,
          _userPostsFuture,
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userDetails = snapshot.data?[0] as Map<String, dynamic>;
          final userPosts = snapshot.data?[1] as List<String>?;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      userDetails['profilePicture'] != null && userDetails['profilePicture'].isNotEmpty
                          ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(userDetails['profilePicture']),
                      )
                          : CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                      SizedBox(height: 16),
                      Text(
                        userDetails['username'] ?? 'No username',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        userDetails['email'] ?? 'No email',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Posts',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 8),
                userPosts == null || userPosts.isEmpty
                    ? Center(child: Text('No posts available'))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: userPosts.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      userPosts[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
