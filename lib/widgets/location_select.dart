import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/auth_provider.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/widgets/snackbar.dart';

class LocationSelect extends StatefulWidget {
  const LocationSelect({super.key});

  @override
  State<LocationSelect> createState() => _LocationSelectState();
}

class _LocationSelectState extends State<LocationSelect> {
  String _selectedLocation = 'Gulshan';
  final List<String> _locations = [
    'Gulshan',
    'Banani',
    'Dhanmondi',
    'Bashundhara R/A',
    'Uttara',
    'Mirpur',
    'Mohammadpur',
    'Farmgate',
    'Motijheel',
    'Badda',
    'Baridhara',
    'Khilgaon',
    'Rampura',
    'Malibagh',
    'Moghbazar',
    'Shahbagh',
    'Paltan',
    'Lalmatia',
    'Tejgaon',
    'Niketon',
    'Agargaon',
    'Shyamoli',
    'Adabor',
    'Gabtoli',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userData != null &&
          authProvider.userData!['location'] != null) {
        setState(() {
          _selectedLocation = authProvider.userData!['location'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Update local state if provider has a different location (e.g. from initial load)
    if (authProvider.userData != null &&
        authProvider.userData!['location'] != null &&
        authProvider.userData!['location'] != _selectedLocation) {
      _selectedLocation = authProvider.userData!['location'];
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
      onSelected: (String newValue) {
        setState(() {
          _selectedLocation = newValue;
        });
        Provider.of<AuthProvider>(
          context,
          listen: false,
        ).updateLocation(newValue);
        CustomSnackBar.show(context, "Location updated to $newValue");
      },
      constraints: const BoxConstraints(maxHeight: 400),
      itemBuilder: (BuildContext context) {
        return _locations.map((String value) {
          return PopupMenuItem<String>(
            height: 30,
            value: value,
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 10,
                  color: _selectedLocation == value
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: _selectedLocation == value
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontWeight: _selectedLocation == value
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0),
              blurRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 16),
            const SizedBox(width: 0),
            Flexible(
              child: Text(
                _selectedLocation,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
