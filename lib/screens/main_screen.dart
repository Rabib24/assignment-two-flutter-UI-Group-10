import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/auth_provider.dart';
import 'package:minimart/screens/shop_page.dart';
import 'package:minimart/screens/cart_page.dart';
import 'package:minimart/screens/orders_page.dart';
import 'package:minimart/screens/wishlist_page.dart';
import 'package:minimart/widgets/app_drawer.dart';
import 'package:minimart/widgets/app_bar.dart';
import 'package:minimart/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const ShopPage(),
    const CartPage(),
    const WishlistPage(),
    const OrdersPage(),
  ];

  final List<String> _titles = ["Shop", "Cart", "Wishlist", "Orders"];

  @override
  void initState() {
    super.initState();
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Check email verification status when app resumes from background
    if (state == AppLifecycleState.resumed) {
      debugPrint('[MainScreen] App resumed - checking email verification status');
      final authManager = Provider.of<AuthManager>(context, listen: false);
      if (authManager.user != null) {
        authManager.checkEmailVerificationStatus();
      }
    }
  }

  @override
  void dispose() {
    // Remove observer to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Log current screen for debugging
    debugPrint('[MainScreen] Building main screen with index: $_selectedIndex');
    return Consumer<AuthManager>(
      builder: (context, authManager, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: _titles[_selectedIndex],
            onMenuPressed: () {
              // Open the end drawer using the scaffold key
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          backgroundColor: const Color(0xFFF8F9FA),
          body: _pages[_selectedIndex],
          endDrawer: const AppDrawer(),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}