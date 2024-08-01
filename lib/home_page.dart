import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:test_app/add_post.dart';
import 'package:test_app/profile_page.dart';
import 'package:test_app/search_page.dart';
import 'package:test_app/feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  int _selectedIndex=0;
  void _navigate(int index){
    setState(() {
      _selectedIndex= index;
    });

  }
  final List< Widget> _pages = [
     MyHomePage(),
    SearchPage(),
    AddPostScreen(),
      ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: GNav(
        //rippleColor: Colors.grey, // tab button ripple color when pressed
        //hoverColor: Colors.grey, // tab button hover color
        haptic: true, // haptic feedback
        tabBorderRadius: 15,
        tabActiveBorder: Border.all(color: Colors.white, width: 1), // tab button border
        tabBorder: Border.all(color: Colors.white, width: 1), // tab button border
        tabShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 8)], // tab button shadow
        curve: Curves.easeOutExpo, // tab animation curves
        duration: Duration(milliseconds: 900), // tab animation duration
        gap: 8, // the tab button gap between icon and text
        color: Colors.grey[800], // unselected icon color
        activeColor: Colors.black, // selected icon and text color
        // tab button icon size
        tabBackgroundColor: Colors.grey.withOpacity(0.3), // selected tab background color
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), // navigation bar padding


        onTabChange:_navigate ,
        tabs: [
          GButton(icon: Icons.home, text: "Home",iconSize: 25,),
          GButton(icon: Icons.search,text: "Search",iconSize: 25,),
          GButton(icon: Icons.add_circle,text: "Photo",iconSize: 25,),
          GButton(icon: Icons.person,text: "Person",iconSize: 25,),
        ],
      ),
    );
  }

}
