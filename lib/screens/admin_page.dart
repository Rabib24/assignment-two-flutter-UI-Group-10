import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minimart/providers/products_provider.dart';
import 'package:minimart/widgets/snackbar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    // Fetch products and categories when page loads
    Future.microtask(() {
      final provider = Provider.of<ProductsProvider>(context, listen: false);
      provider.fetchProducts(); // This will also call fetchCategories()
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final products = productsProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(product.imageUrl),
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(product.name),
            subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditProductDialog(context, product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, product.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Product?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await Provider.of<ProductsProvider>(context, listen: false)
                    .deleteProduct(productId);
                if (mounted) CustomSnackBar.show(context, "Product deleted");
              } catch (e) {
                if (mounted) CustomSnackBar.show(context, "Error: $e", isError: true);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = "General";
    String? customCategory;
    final descController = TextEditingController();
    final urlController = TextEditingController();
    final customCatController = TextEditingController();
    bool showCustomCategory = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Add Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Consumer<ProductsProvider>(
                  builder: (context, productsProvider, child) {
                    var categories = productsProvider.categories.toList();
                    // Ensure "General" is in the list
                    if (!categories.contains("General")) {
                      categories.insert(0, "General");
                    }
                    // Ensure selected category is in the list
                    if (!categories.contains(selectedCategory) && selectedCategory != "Other") {
                      categories.add(selectedCategory);
                      categories.sort();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Category", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value ?? "General";
                              showCustomCategory = (value == "Other");
                            });
                          },
                          items: [
                            ...categories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            )),
                            const DropdownMenuItem(
                              value: "Other",
                              child: Text("Other"),
                            ),
                          ],
                        ),
                        if (showCustomCategory)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextField(
                              controller: customCatController,
                              decoration: const InputDecoration(
                                labelText: "Enter new category",
                                hintText: "e.g., Electronics",
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: "Image URL"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  CustomSnackBar.show(context, "Name and Price are required", isError: true);
                  return;
                }

                String finalCategory = selectedCategory;
                if (showCustomCategory && customCatController.text.isNotEmpty) {
                  finalCategory = customCatController.text;
                }

                Navigator.pop(ctx);
                try {
                  await Provider.of<ProductsProvider>(context, listen: false)
                      .addProduct({
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'category': finalCategory,
                    'description': descController.text,
                    'imageUrl': urlController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (mounted) CustomSnackBar.show(context, "Product added");
                } catch (e) {
                  if (mounted) CustomSnackBar.show(context, "Error: $e", isError: true);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, dynamic product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    String selectedCategory = product.category;
    String? customCategory;
    final descController = TextEditingController(text: product.description);
    final urlController = TextEditingController(text: product.imageUrl);
    final customCatController = TextEditingController();
    bool showCustomCategory = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Consumer<ProductsProvider>(
                  builder: (context, productsProvider, child) {
                    var categories = productsProvider.categories.toList();
                    // Ensure selected category is in the list
                    if (!categories.contains(selectedCategory) && selectedCategory != "Other") {
                      categories.add(selectedCategory);
                      categories.sort();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Category", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value ?? "General";
                              showCustomCategory = (value == "Other");
                            });
                          },
                          items: [
                            ...categories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            )),
                            const DropdownMenuItem(
                              value: "Other",
                              child: Text("Other"),
                            ),
                          ],
                        ),
                        if (showCustomCategory)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextField(
                              controller: customCatController,
                              decoration: const InputDecoration(
                                labelText: "Enter new category",
                                hintText: "e.g., Electronics",
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: "Image URL"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  CustomSnackBar.show(context, "Name and Price are required", isError: true);
                  return;
                }

                String finalCategory = selectedCategory;
                if (showCustomCategory && customCatController.text.isNotEmpty) {
                  finalCategory = customCatController.text;
                }

                Navigator.pop(ctx);
                try {
                  await Provider.of<ProductsProvider>(context, listen: false)
                      .updateProduct(product.id, {
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'category': finalCategory,
                    'description': descController.text,
                    'imageUrl': urlController.text,
                  });
                  if (mounted) CustomSnackBar.show(context, "Product updated");
                } catch (e) {
                  if (mounted) CustomSnackBar.show(context, "Error: $e", isError: true);
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
