import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/auth_provider.dart';
import 'package:minimart/screens/profile_page.dart';
import 'package:minimart/auth/login_screen.dart';
import 'package:minimart/widgets/snackbar.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          final userData = auth.userData;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE2D9), // Soft Peach
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: Color(0xFFFF6B6B)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userData?['name'] ?? user?.email ?? 'Hello, Shopper!',
                      style: const TextStyle(
                        fontSize: 16, // Slightly smaller to fit email
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF636E72),
                ),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF636E72),
                ),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to Settings Page
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFF6B6B)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await auth.signOut();
                  if (context.mounted) {
                    CustomSnackBar.show(context, "Logged out successfully");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
