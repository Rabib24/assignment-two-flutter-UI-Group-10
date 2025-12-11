import 'package:flutter/material.dart';
import 'package:minimart/models/product.dart';
import 'package:minimart/screens/category_products_page.dart';
import 'package:minimart/providers/products_provider.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/widgets/product_grid_item.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _sortBy = 'default'; // default, price_asc, price_desc

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
      }
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productsData, child) {
        final products = productsData.products;
        
        // Filter and Sort Logic
        List<Product> filteredProducts = products;
        
        if (_searchQuery.isNotEmpty) {
          filteredProducts = products.where((p) => 
            p.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (_sortBy == 'price_asc') {
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        } else if (_sortBy == 'price_desc') {
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        }

        final bool isSearchingOrSorting = _searchQuery.isNotEmpty || _sortBy != 'default';

        return Scaffold(
           body: RefreshIndicator(
            onRefresh: () => Provider.of<ProductsProvider>(
              context,
              listen: false,
            ).fetchProducts(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Search Bar & Sort Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Search products...",
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.sort),
                                onSelected: (value) {
                                  setState(() {
                                    _sortBy = value;
                                  });
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'default',
                                    child: Text('Default'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'price_asc',
                                    child: Text('Price: Low to High'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'price_desc',
                                    child: Text('Price: High to Low'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        if (!isSearchingOrSorting) ...[
                          const SizedBox(height: 20),
                          // Banners logic
                           SizedBox(
                            height: 180,
                            child: PageView(
                              children: [
                                _buildBanner(
                                  colors: [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
                                  icon: Icons.shopping_bag_outlined,
                                  title: "Summer Sale",
                                  subtitle: "Up to 50% OFF",
                                ),
                                _buildBanner(
                                  colors: [const Color(0xFFFF7675), const Color(0xFFFF9F43)],
                                  icon: Icons.local_offer_outlined,
                                  title: "New Arrivals",
                                  subtitle: "Check out the latest trends",
                                ),
                                _buildBanner(
                                  colors: [const Color(0xFF00B894), const Color(0xFF55EFC4)],
                                  icon: Icons.eco_outlined,
                                  title: "Fresh & Organic",
                                  subtitle: "Straight from the farm",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (isSearchingOrSorting)
                   SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: filteredProducts.isEmpty 
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50.0),
                              child: Text("No products found"),
                            ),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ProductGridItem(product: filteredProducts[index]);
                            },
                            childCount: filteredProducts.length,
                          ),
                        ),
                  )
                else if (products.isEmpty)
                  const SliverToBoxAdapter(
                     child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                         // Re-using the category grouping logic adapted for SliverList
                         // Ideally we pre-calculate sections. For simplicity, we can just use a column in an adapter or restructure.
                         // To keep it simple and clean with the previous design, let's just stick to the previous column-based layout inside a SliverToBoxAdapter 
                         // or use a helper that returns a list of widgets.
                         
                         // BUT SliverList needs index.
                         // Let's just put the existing category logic into a single SliverToBoxAdapter for the default view
                         // or use the ListView inside the RefreshIndicator body if not needing slivers.
                         // However, I switched to CustomScrollView to handle the scrolling of search bar + content together nicely.
                        return null; 
                      },
                      childCount: 0, 
                    ),
                  ),
                  
                  // Fixing the structure for Default View
                 if (!isSearchingOrSorting && products.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
                        children: _buildCategorySections(context, products),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner({
    required List<Color> colors,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
      return Container(
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 140,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  List<Widget> _buildCategorySections(
    BuildContext context,
    List<Product> products,
  ) {
    // Group products by category
    final Map<String, List<Product>> productsByCategory = {};
    for (var product in products) {
      if (!productsByCategory.containsKey(product.category)) {
        productsByCategory[product.category] = [];
      }
      productsByCategory[product.category]!.add(product);
    }

    // Build a section for each category
    return productsByCategory.entries.map((entry) {
      final category = entry.key;
      final categoryProducts = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Fixed padding to match Search bar
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => CategoryProductsPage(
                          category: category,
                          products: categoryProducts,
                        ),
                      ),
                    );
                  },
                  child: const Text("See All"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16), // Padding for first item
              itemCount: categoryProducts.length,
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                return Container(
                  width: 180, 
                  margin: const EdgeInsets.only(right: 16),
                  child: ProductGridItem(product: product),
                );
              },
            ),
          ),
        ],
      );
    }).toList();
  }
}
