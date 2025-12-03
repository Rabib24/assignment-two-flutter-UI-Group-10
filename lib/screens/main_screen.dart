import 'package:flutter/material.dart';

import 'package:minimart/screens/shop_page.dart';
import 'package:minimart/screens/cart_page.dart';
import 'package:minimart/screens/orders_page.dart';
import 'package:minimart/widgets/app_drawer.dart';
import 'package:minimart/widgets/app_bar.dart';
import 'package:minimart/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ShopPage(),
    const CartPage(),
    const OrdersPage(),
  ];

  final List<String> _titles = ["Shop", "Cart", "Orders"];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _titles[_selectedIndex]),
      backgroundColor: const Color(0xFFF8F9FA),
      body: _pages[_selectedIndex],
      endDrawer: const AppDrawer(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
