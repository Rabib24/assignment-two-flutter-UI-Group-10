import 'package:flutter/material.dart';
import 'package:minimart/models/product.dart';
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
  String _selectedCategory = 'All'; // Category filter
  bool _hasLoadedProducts = false;

  @override
  void initState() {
    super.initState();
    // Debounced search - avoid rebuilds on every keystroke
    _searchController.addListener(_debounceSearch);
  }

  late Future<void> _searchDebounce;

  void _debounceSearch() async {
    // Cancel previous timer if exists
    await _searchDebounce;
    
    _searchDebounce = Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
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
        final isLoading = productsData.isLoading;
        final errorMessage = productsData.errorMessage;
        
        // Fetch products only once on first build
        if (!_hasLoadedProducts && products.isEmpty && !isLoading) {
          _hasLoadedProducts = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              productsData.fetchProducts();
            }
          });
        }
        
        // Filter and Sort Logic
        List<Product> filteredProducts = products;
        
        // Apply category filter
        if (_selectedCategory != 'All') {
          filteredProducts = filteredProducts.where((p) => p.category == _selectedCategory).toList();
        }
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          filteredProducts = filteredProducts.where((p) => 
            p.name.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (_sortBy == 'price_asc') {
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        } else if (_sortBy == 'price_desc') {
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        }

        final bool isSearchingOrSorting = _searchQuery.isNotEmpty || _sortBy != 'default' || _selectedCategory != 'All';

        return Scaffold(
           body: RefreshIndicator(
            onRefresh: () async {
              
              await Provider.of<ProductsProvider>(
                context,
                listen: false,
              ).fetchProducts();
            },
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
                        const SizedBox(height: 16),
                        // Category Dropdown
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _getUniqueCategories(products).map((String category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                }
                              },
                            ),
                          ),
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

                if (errorMessage.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _hasLoadedProducts = false; // Reset to allow retry
                                });
                                productsData.fetchProducts();
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (isLoading && products.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (isSearchingOrSorting)
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
                     child: Center(
                       child: Padding(
                         padding: EdgeInsets.all(50.0),
                         child: Column(
                           children: [
                             Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                             SizedBox(height: 16),
                             Text(
                               "No products available",
                               style: TextStyle(fontSize: 16, color: Colors.grey),
                             ),
                           ],
                         ),
                       ),
                     ),
                  )
                  // Default View - Display ALL products in a grid view
                 else if (!isSearchingOrSorting && products.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProductGridItem(product: products[index]);
                          },
                          childCount: products.length,
                        ),
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

  List<String> _getUniqueCategories(List<Product> products) {
    final categories = {'All'};
    for (final product in products) {
      if (product.category.isNotEmpty) {
        categories.add(product.category);
      }
    }
    return categories.toList()..sort();
  }


}