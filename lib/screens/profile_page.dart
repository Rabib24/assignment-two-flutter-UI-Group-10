import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/auth_provider.dart'; // This imports the file, but we use AuthManager
import 'package:minimart/providers/theme_provider.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/screens/admin_page.dart';

import 'package:minimart/widgets/snackbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthManager>(context); // Changed from AuthProvider to AuthManager
    final user = authProvider.user;
    final userData = authProvider.userData;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFFFE2D9),
                child: Icon(Icons.person, size: 50, color: Color(0xFFFF6B6B)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userData?['name'] ?? user?.email ?? "No Name",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF636E72),
                    ),
                    title: const Text("Name"),
                    subtitle: Text(userData?['name'] ?? "Not set"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFF6B6B)),
                      onPressed: () {
                        final nameController = TextEditingController(
                          text: userData?['name'] ?? "",
                        );
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Edit Name"),
                            content: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                hintText: "Enter new name",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final newName = nameController.text.trim();
                                  if (newName.isNotEmpty) {
                                    try {
                                      await authProvider.updateName(newName);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        CustomSnackBar.show(
                                          context,
                                          "Name updated successfully",
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        CustomSnackBar.show(
                                          context,
                                          e.toString(),
                                          isError: true,
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF636E72),
                    ),
                    title: const Text("Email"),
                    subtitle: Text(user?.email ?? "Not set"),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF636E72),
                    ),
                    title: const Text("Phone Number"),
                    subtitle: Text(userData?['phoneNumber'] ?? "Not set"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFF6B6B)),
                      onPressed: () {
                        final phoneController = TextEditingController(
                          text: userData?['phoneNumber'] ?? "",
                        );
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Edit Phone Number"),
                            content: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: "Enter new phone number",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final newPhone = phoneController.text.trim();
                                  if (newPhone.isNotEmpty) {
                                    try {
                                      await authProvider.updatePhone(newPhone);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        CustomSnackBar.show(
                                          context,
                                          "Phone number updated successfully",
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        CustomSnackBar.show(
                                          context,
                                          e.toString(),
                                          isError: true,
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: const Color(0xFF636E72),
                    ),
                    title: const Text("Dark Mode"),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeThumbColor: AppColors.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                title: const Text("Admin Panel"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => const AdminPage()), // Need import
                   );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}