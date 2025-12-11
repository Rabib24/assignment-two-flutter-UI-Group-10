import 'package:flutter/material.dart';
import 'package:minimart/models/product.dart';
import 'package:minimart/providers/products_provider.dart';
import 'package:minimart/providers/wishlist_provider.dart';
import 'package:minimart/widgets/product_grid_item.dart';
import 'package:provider/provider.dart';
import 'package:minimart/theme/app_colors.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<WishlistProvider, ProductsProvider>(
        builder: (context, wishlistProvider, productsProvider, child) {
          final wishlistIds = wishlistProvider.wishlistIds;
          final allProducts = productsProvider.products;
          
          final wishlistProducts = allProducts
              .where((p) => wishlistIds.contains(p.id))
              .toList();

          if (wishlistProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Your wishlist is empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              return ProductGridItem(product: wishlistProducts[index]);
            },
          );
        },
      ),
    );
  }
}
