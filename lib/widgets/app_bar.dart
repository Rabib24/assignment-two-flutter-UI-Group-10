import 'package:flutter/material.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/widgets/location_select.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed; // Add callback for menu press

  const CustomAppBar({super.key, required this.title, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 5,
      leadingWidth: 140,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: SizedBox(
          height: 40,
          child: const LocationSelect(),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF9F43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onMenuPressed ?? () {
            // Fallback to opening the end drawer if callback is not provided
            final ScaffoldState? scaffold = Scaffold.maybeOf(context);
            if (scaffold != null) {
              scaffold.openEndDrawer();
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}