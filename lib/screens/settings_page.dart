import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/auth_provider.dart';
import 'package:minimart/providers/theme_provider.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/widgets/snackbar.dart';
import 'package:minimart/screens/admin_page.dart';
import 'package:minimart/screens/documentation_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthManager>(context);
    final user = authProvider.user;
    final userData = authProvider.userData;
    
    // Check if user is admin
    final isAdmin = userData != null && userData['userRole'] == 'admin';
    
    // Optimize performance by caching values
    final userName = userData?['name'] ?? "Not set";
    final userEmail = user?.email ?? "Not set";
    final userPhone = userData?['phoneNumber'] ?? "Not set";
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

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
                child: Icon(Icons.settings, size: 50, color: Color(0xFFFF6B6B)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 32),
            
            // User Information Section
            _buildUserInfoSection(context, authProvider, userName, userEmail, userPhone),
            
            const SizedBox(height: 24),
            
            // Theme Settings
            _buildThemeSection(context),
            
            const SizedBox(height: 24),
            
            // Documentation Section
            _buildDocumentationSection(context),
            
            const SizedBox(height: 24),
            
            // Admin Panel Access - Only show if user is admin
            if (isAdmin)
              _buildAdminPanelSection(context)
            else
              _buildAdminRestrictedSection(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInfoSection(BuildContext context, AuthManager authProvider, String userName, String userEmail, String userPhone) {
    return Container(
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
            subtitle: Text(userName),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFFF6B6B)),
              onPressed: () => _showEditDialog(context, "Edit Name", userName, (newValue) async {
                try {
                  await authProvider.updateName(newValue);
                  if (mounted) {
                    CustomSnackBar.show(context, "Name updated successfully");
                  }
                } catch (e) {
                  if (mounted) {
                    CustomSnackBar.show(context, e.toString(), isError: true);
                  }
                }
              }),
            ),
          ),
          const Divider(height: 1),
          Consumer<AuthManager>(
            builder: (context, authManager, child) {
              final isVerified = authManager.isEmailVerified();
              return ListTile(
                leading: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF636E72),
                ),
                title: const Text("Email"),
                subtitle: Text(userEmail),
                trailing: SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVerified ? Icons.check_circle : Icons.pending_actions,
                        color: isVerified ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isVerified ? 'Verified' : 'Unverified',
                          style: TextStyle(
                            fontSize: 12,
                            color: isVerified ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF636E72),
            ),
            title: const Text("Phone Number"),
            subtitle: Text(userPhone),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFFF6B6B)),
              onPressed: () => _showEditDialog(context, "Edit Phone Number", userPhone, (newValue) async {
                try {
                  await authProvider.updatePhone(newValue);
                  if (mounted) {
                    CustomSnackBar.show(context, "Phone number updated successfully");
                  }
                } catch (e) {
                  if (mounted) {
                    CustomSnackBar.show(context, e.toString(), isError: true);
                  }
                }
              }, isPhone: true),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeSection(BuildContext context) {
    return Container(
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
    );
  }
  
  Widget _buildDocumentationSection(BuildContext context) {
    return Container(
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
        leading: const Icon(Icons.description_outlined, color: Color(0xFF0984E3)),
        title: const Text("Documentation"),
        subtitle: const Text("Project documentation and guides"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DocumentationPage()),
          );
        },
      ),
    );
  }
  
  Widget _buildAdminPanelSection(BuildContext context) {
    return Container(
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
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        },
      ),
    );
  }
  
  Widget _buildAdminRestrictedSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
        leading: const Icon(Icons.admin_panel_settings, color: Colors.grey),
        title: const Text("Admin Panel"),
        subtitle: const Text("Admin access only"),
        trailing: const Icon(Icons.lock, size: 16, color: Colors.grey),
        enabled: false,
      ),
    );
  }
  
  void _showEditDialog(BuildContext context, String title, String initialValue, Function(String) onSave, {bool isPhone = false}) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: isPhone ? "Enter new phone number" : "Enter new name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                Navigator.pop(context);
                await onSave(newValue);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}