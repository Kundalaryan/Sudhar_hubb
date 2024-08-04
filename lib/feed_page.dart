import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/comment_page.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'सुधारHub',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 25),
          ),
        ),
      ),
      body: PostCard(),
    );
  }
}

class PostCard extends StatefulWidget {
  const PostCard({Key? key}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUserId;
  Map<String, bool> showLocationMap = {};

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.uid ?? '';
  }

  List<String> reportReasons = [
    'Inappropriate content',
    'Spam or misleading',
    'Harassment or hate speech',
    'Intellectual property violation',
    'Other',
  ];

  String? selectedReason;

  void selectReason(String? reason) {
    setState(() {
      selectedReason = reason;
    });
  }

  void reportPost() {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a reason"),
        ),
      );
    } else {
      print("Post reported with reason: $selectedReason");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post reported"),
        ),
      );
      // Clear the selected reason after reporting
      setState(() {
        selectedReason = null;
      });
    }
  }

  void toggleLocation(String postId) {
    setState(() {
      showLocationMap[postId] = !(showLocationMap[postId] ?? false);
    });
  }

  void updateLikeStatus(String postId, bool like) async {
    DocumentReference postRef = _firestore.collection('posts').doc(postId);
    DocumentSnapshot postSnapshot = await postRef.get();
    Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;

    List<String> likes = List<String>.from(postData['likes'] ?? []);
    List<String> dislikes = List<String>.from(postData['dislikes'] ?? []);

    if (like) {
      if (!likes.contains(currentUserId)) {
        likes.add(currentUserId);
        if (dislikes.contains(currentUserId)) {
          dislikes.remove(currentUserId);
        }
        await postRef.update({
          'likes': likes,
          'dislikes': dislikes,
        });
      }
    } else {
      if (!dislikes.contains(currentUserId)) {
        dislikes.add(currentUserId);
        if (likes.contains(currentUserId)) {
          likes.remove(currentUserId);
        }
        await postRef.update({
          'likes': likes,
          'dislikes': dislikes,
        });
      }
    }
  }

  Future<int> getCommentsCount(String postId) async {
    QuerySnapshot commentsSnapshot = await _firestore.collection('posts').doc(postId).collection('comments').get();
    return commentsSnapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot post = snapshot.data!.docs[index];
            Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
            String postId = post.id;

            List<String> likes = List<String>.from(postData['likes'] ?? []);
            List<String> dislikes = List<String>.from(postData['dislikes'] ?? []);
            bool hasLiked = likes.contains(currentUserId);
            bool hasDisliked = dislikes.contains(currentUserId);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      postData['username'] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: postData['profilePicture'] != null && postData['profilePicture'] != ''
                          ? NetworkImage(postData['profilePicture'])
                          : null,
                      child: postData['profilePicture'] == null || postData['profilePicture'] == ''
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.report_outlined,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: const Text("Report Post"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: reportReasons
                                        .map(
                                          (reason) => RadioListTile<String>(
                                        title: Text(reason),
                                        value: reason,
                                        groupValue: selectedReason,
                                        onChanged: (value) {
                                          selectReason(value);
                                        },
                                      ),
                                    )
                                        .toList(),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("Report"),
                                      onPressed: () {
                                        reportPost();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Image.network(
                    postData['imageUrl'] ?? '',
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            updateLikeStatus(postId, true);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                size: 30,
                                color: hasLiked ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${likes.length}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            updateLikeStatus(postId, false);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.thumb_down,
                                size: 30,
                                color: hasDisliked ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${dislikes.length}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentPage(postId: postId),
                                ),
                              );
                            },
                            icon: Icon(Icons.chat_bubble_outline),
                            iconSize: 30,
                          ),
                        ),
                        const Spacer(),
                        if (showLocationMap[postId] ?? false)
                          GestureDetector(
                            onTap: () {
                              toggleLocation(postId);
                            },
                            child: Text(
                              postData['location'] ?? 'No location',
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () {
                              toggleLocation(postId);
                            },
                            icon: const Icon(Icons.location_on_outlined),
                            iconSize: 30,
                            color: Colors.black,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${postData['username'] ?? 'Anonymous'}: ${postData['Caption'] ?? 'No caption'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: _firestore.collection('posts').doc(postId).collection('comments').snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text('Loading comments...');
                            }

                            int commentsCount = snapshot.data!.size;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommentPage(postId: postId),
                                  ),
                                );
                              },
                              child: Text(
                                'View all $commentsCount comments',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
