import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/provider/auth_provider.dart';
import 'package:test_app/provider/theme_provider.dart';
import 'edit_profile_page.dart'; // Import the EditProfilePage

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = false;
  String selectedLanguage = 'English'; // Default language

  final List<String> languages = ['English', 'Hindi']; // Add more languages here

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Get the ThemeProvider instance
    return Scaffold(
      appBar: AppBar(

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text('Settings'),
        leadingWidth: 60,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 30),

              const SizedBox(height: 20),
              _buildSettingOption(
                icon: Icons.language_outlined,
                color: Colors.red,
                title: "Language",
                subtitle: selectedLanguage,
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              const SizedBox(height: 20),
              _buildSettingOption(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                title: "Edit Profile",
                subtitle: "",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  EditProfilePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSettingOption(
                icon: themeProvider.isDarkTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                color: themeProvider.isDarkTheme ? Colors.yellow : Colors.blue,
                title: "Mode",
                subtitle: themeProvider.isDarkTheme ? "Dark Mode" : "Light Mode",
                onTap: () {
                  setState(() {
                    themeProvider.toggleTheme();
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildSettingOption(
                icon: Icons.logout_outlined,
                color: Colors.red,
                title: "Log Out",
                subtitle: "",
                onTap: () {
                  Provider.of<AuthProvider>(context, listen: false).logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              return ListTile(
                title: Text(language),
                onTap: () {
                  setState(() {
                    selectedLanguage = language;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    void Function()? onTap,
  }) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 20),
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}
