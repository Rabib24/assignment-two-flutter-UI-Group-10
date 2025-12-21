# Member 3 - Technical Documentation: Widgets & Functions

**Focus Area:** Admin Panel Enhancement, Bug Fixes, Order Details Page, and Project Compliance

---

## Table of Contents
1. [Admin Panel Enhancement](#admin-panel-enhancement)
2. [Dynamic Category Management](#dynamic-category-management)
3. [Product Edit Functionality](#product-edit-functionality)
4. [Order Details Page](#order-details-page)
5. [Bug Fixes & Improvements](#bug-fixes-improvements)
6. [Email Verification Auto-Refresh](#email-verification-auto-refresh)

---

## 1. Admin Panel Enhancement

### File: `lib/screens/admin_page.dart`

#### **StatefulWidget for Admin Page**
```dart
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<ProductsProvider>(context, listen: false);
      provider.fetchProducts();
    });
  }
}
```
**Purpose:** Admin interface for managing products with CRUD operations.

**How it works:**
- `StatefulWidget`: Enables local state management for dialog forms
- `initState()`: Called once when widget is created
- `Future.microtask()`: Schedules callback after current frame
- Fetches products and categories when page loads
- `listen: false`: Avoids listening to provider in initState

---

#### **ListView.builder for Product List**
```dart
ListView.builder(
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
)
```
**Purpose:** Displays all products in a scrollable list with edit/delete actions.

**How it works:**
- `itemBuilder`: Creates ListTile for each product
- `CircleAvatar`: Displays product image in circular format
- `onBackgroundImageError`: Prevents errors if image fails to load
- `trailing`: Row with edit and delete buttons
- `mainAxisSize.min`: Row takes minimum space needed
- Color-coded icons: Blue for edit, red for delete

---

#### **FloatingActionButton for Add Product**
```dart
floatingActionButton: FloatingActionButton(
  onPressed: () => _showProductDialog(context),
  child: const Icon(Icons.add),
)
```
**Purpose:** Provides quick access to add new product dialog.

**How it works:**
- Circular button that floats over content (bottom-right by default)
- `onPressed`: Opens add product dialog
- Plus icon indicates "add" action
- Material Design standard for primary action

---

#### **Delete Confirmation Dialog**
```dart
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
              if (mounted) CustomSnackBar.show(
                context, 
                "Error: $e", 
                isError: true
              );
            }
          },
          child: const Text("Delete", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```
**Purpose:** Prevents accidental deletion by requiring confirmation.

**How it works:**
- Shows alert dialog with warning message
- Two options: Cancel or Delete
- Cancel: Closes dialog without action
- Delete: 
  1. Closes dialog
  2. Calls provider's deleteProduct method
  3. Shows success/error message
- Red text on Delete button emphasizes danger
- `mounted` check: Ensures widget exists before showing snackbar

---

## 2. Dynamic Category Management

### File: `lib/screens/admin_page.dart`

#### **StatefulBuilder for Dynamic Dropdown**
```dart
showDialog(
  context: context,
  builder: (ctx) => StatefulBuilder(
    builder: (ctx, setState) => AlertDialog(
      title: const Text("Add Product"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form fields
            Consumer<ProductsProvider>(
              builder: (context, productsProvider, child) {
                var categories = productsProvider.categories.toList();
                // ... dropdown logic
              },
            ),
          ],
        ),
      ),
    ),
  ),
);
```
**Purpose:** Allows dropdown state to update within dialog without closing it.

**How it works:**
- `StatefulBuilder`: Creates stateful context within stateless dialog
- `setState` parameter: Local setState for dialog only
- Enables dropdown value changes without rebuilding entire page
- `Consumer<ProductsProvider>`: Accesses dynamic category list
- `SingleChildScrollView`: Makes dialog scrollable for many fields

---

#### **Dynamic Category Dropdown with "Other" Option**
```dart
Consumer<ProductsProvider>(
  builder: (context, productsProvider, child) {
    var categories = productsProvider.categories.toList();
    
    // Ensure "General" exists as fallback
    if (!categories.contains("General")) {
      categories.insert(0, "General");
    }
    
    // Ensure selectedCategory is valid
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
)
```
**Purpose:** Dynamically populates dropdown with existing categories plus option to create new ones.

**How it works:**
1. **Fetch Categories**: Gets list from ProductsProvider
2. **Ensure "General" Exists**: Adds default category if missing
3. **Validate Selected Category**: 
   - If selectedCategory not in list, adds it
   - Prevents dropdown crash from invalid value
4. **Dropdown Items**:
   - Maps all existing categories to dropdown items
   - Adds "Other" option at the end
5. **"Other" Selection**:
   - Sets `showCustomCategory = true`
   - Shows text field for custom category input
6. **Dynamic Addition**: New categories immediately available in dropdown

**Critical Bug Fix:** Prevents "DropdownButton value mismatch" crash by ensuring selected value always exists in items list.

---

#### **Category Persistence Logic**
```dart
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
)
```
**Purpose:** Validates form and saves product with correct category.

**How it works:**
1. **Validation**: Checks name and price are provided
2. **Category Resolution**:
   - If "Other" selected and custom text entered: Use custom category
   - Otherwise: Use selected category from dropdown
3. **Close Dialog**: `Navigator.pop()`
4. **Add Product**: Calls provider method with product data
5. **Firestore Timestamp**: `FieldValue.serverTimestamp()` adds server-side timestamp
6. **Error Handling**: Shows success or error message
7. **Type Conversion**: `double.tryParse()` safely converts price string to double

---

## 3. Product Edit Functionality

### File: `lib/screens/admin_page.dart`

#### **Edit Product Dialog with Pre-populated Data**
```dart
void _showEditProductDialog(BuildContext context, dynamic product) {
  final nameController = TextEditingController(text: product.name);
  final priceController = TextEditingController(text: product.price.toString());
  String selectedCategory = product.category;
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
              // Category dropdown (same as add product)
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
              // Update logic
            },
            child: const Text("Update"),
          ),
        ],
      ),
    ),
  );
}
```
**Purpose:** Allows editing existing product with all fields pre-filled.

**How it works:**
1. **Pre-population**: TextEditingController initialized with current product values
2. **Same Form**: Reuses same UI as add product
3. **Dialog Title**: "Edit Product" vs "Add Product"
4. **Category Handling**: 
   - Pre-selects current category
   - Ensures it exists in dropdown to prevent crash
5. **Update Button**: Calls updateProduct instead of addProduct

---

#### **Update Product Logic**
```dart
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
)
```
**Purpose:** Saves edited product data to Firestore.

**How it works:**
- Similar to add product but uses `updateProduct()`
- Passes `product.id` to identify which product to update
- Firestore `.update()`: Only updates specified fields, preserves others
- No `createdAt` timestamp (keeps original creation date)
- Validation and error handling same as add product

---

### File: `lib/providers/products_provider.dart`

#### **Async Product Update Method**
```dart
Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
  try {
    await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .update(updates);
    
    // Update local state
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = Product(
        id: productId,
        name: updates['name'] ?? _products[index].name,
        price: updates['price'] ?? _products[index].price,
        category: updates['category'] ?? _products[index].category,
        description: updates['description'] ?? _products[index].description,
        imageUrl: updates['imageUrl'] ?? _products[index].imageUrl,
      );
      notifyListeners();
    }
    
    await fetchCategories(); // Refresh categories
  } catch (e) {
    throw 'Failed to update product: $e';
  }
}
```
**Purpose:** Updates product in Firestore and local state.

**How it works:**
1. **Firestore Update**: `.update()` modifies specific fields
2. **Find Local Product**: `indexWhere()` finds product by ID
3. **Update Local State**: Creates new Product object with updated values
4. **Null Coalescing**: `??` keeps old value if update doesn't provide new one
5. **Notify Listeners**: Rebuilds UI with updated data
6. **Refresh Categories**: If category changed, updates category list
7. **Error Handling**: Throws descriptive error message

**Bug Fix:** Properly declares async method with Future return type, fixing "orphaned code" issue.

---

## 4. Order Details Page

### File: `lib/screens/order_details_page.dart`

#### **OrderDetailsPage Widget Structure**
```dart
class OrderDetailsPage extends StatelessWidget {
  final OrderItem order;
  
  const OrderDetailsPage({super.key, required this.order});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text(
              "Order Details",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF9F43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order header, customer info, items, summary
              ],
            ),
          ),
        );
      },
    );
  }
}
```
**Purpose:** Displays comprehensive order information including customer details, items, payment, and coupon.

**How it works:**
- Receives `OrderItem` object as parameter
- `Consumer<ProductsProvider>`: Accesses product data to show images
- Gradient AppBar: Matches checkout page styling
- `SingleChildScrollView`: Makes entire page scrollable
- Sections for header, customer info, payment, coupon, items, summary

---

#### **Gradient AppBar with flexibleSpace**
```dart
appBar: AppBar(
  title: const Text(
    "Order Details",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, Color(0xFFFF9F43)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
    onPressed: () => Navigator.pop(context),
  ),
)
```
**Purpose:** Creates visually appealing gradient app bar.

**How it works:**
- `backgroundColor: Colors.transparent`: Makes AppBar transparent
- `elevation: 0`: Removes shadow
- `flexibleSpace`: Container behind AppBar content
- `LinearGradient`: Smooth color transition
- `begin/end`: Diagonal gradient direction
- White text and icons for contrast against gradient

---

#### **Order Header with Status Badge**
```dart
Container(
  padding: const EdgeInsets.all(16),
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
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Order ID", style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              )),
              const SizedBox(height: 4),
              Text(order.id, style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              order.status,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      // Order date/time
    ],
  ),
)
```
**Purpose:** Shows order ID and status prominently at the top.

**How it works:**
- Card container with shadow for elevation
- Row with space-between alignment
- Left: Order ID with label
- Right: Status badge
- Badge styling:
  - Semi-transparent background (10% opacity)
  - Primary color text
  - Rounded corners
  - Small font for compact look

---

#### **Date Formatting with intl Package**
```dart
import 'package:intl/intl.dart';

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Order Date"),
        Text(DateFormat('MMM dd, yyyy').format(order.dateTime)),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Order Time"),
        Text(DateFormat('hh:mm a').format(order.dateTime)),
      ],
    ),
  ],
)
```
**Purpose:** Displays order date and time in human-readable format.

**How it works:**
- `intl` package: Provides internationalization and date formatting
- `DateFormat()`: Creates formatter with pattern
- `'MMM dd, yyyy'`: "Dec 19, 2024"
- `'hh:mm a'`: "02:30 PM"
- `.format(dateTime)`: Converts DateTime to formatted string
- Split into date and time for better readability

---

#### **Customer Information Section**
```dart
const Text("Customer Information", style: TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
)),
const SizedBox(height: 12),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow("Name", order.customerName),
      const SizedBox(height: 12),
      _buildInfoRow("Phone", order.customerPhone),
      const SizedBox(height: 12),
      _buildInfoRow("Address", order.customerAddress, multiline: true),
    ],
  ),
)
```
**Purpose:** Displays customer's delivery information.

**How it works:**
- Section header with bold text
- Card container with border
- `_buildInfoRow()`: Reusable helper for label-value pairs
- `multiline: true` for address allows text wrapping
- `width: double.infinity`: Card fills available width

---

#### **Info Row Helper Widget**
```dart
Widget _buildInfoRow(String label, String value, {bool multiline = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        maxLines: multiline ? 3 : 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
```
**Purpose:** Creates consistent label-value display pairs.

**How it works:**
- Returns Column with label above value
- Label: Grey, smaller font, medium weight
- Value: Dark text, larger font, semi-bold
- `maxLines`: Controls text wrapping
- `overflow: TextOverflow.ellipsis`: Shows "..." if text too long
- Reusable for name, phone, address

---

#### **Conditional Payment Method Display**
```dart
if (order.paymentMethod != null) ...[
  const Text("Payment Method"),
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Icon(
          _getPaymentMethodIcon(order.paymentMethod!),
          color: _getPaymentMethodColor(order.paymentMethod!),
        ),
        const SizedBox(width: 12),
        Text(
          _getPaymentMethodName(order.paymentMethod!),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  ),
  const SizedBox(height: 24),
]
```
**Purpose:** Shows payment method with appropriate icon and color.

**How it works:**
- `if (order.paymentMethod != null)`: Only shows if payment method exists
- Spread operator `...[]`: Adds multiple widgets conditionally
- Icon and text in row
- Helper methods determine icon, color, and display name

---

#### **Payment Method Helper Functions**
```dart
IconData _getPaymentMethodIcon(String paymentMethod) {
  switch (paymentMethod) {
    case 'cod':
      return Icons.money;
    case 'card':
      return Icons.credit_card;
    case 'mobile_money':
      return Icons.phone_android;
    default:
      return Icons.payment;
  }
}

Color _getPaymentMethodColor(String paymentMethod) {
  switch (paymentMethod) {
    case 'cod':
      return Colors.green;
    case 'card':
      return Colors.blue;
    case 'mobile_money':
      return Colors.pink;
    default:
      return AppColors.primary;
  }
}

String _getPaymentMethodName(String paymentMethod) {
  switch (paymentMethod) {
    case 'cod':
      return 'Cash on Delivery';
    case 'card':
      return 'Credit/Debit Card';
    case 'mobile_money':
      return 'Mobile Money (Bkash/Nagad)';
    default:
      return 'Unknown Payment Method';
  }
}
```
**Purpose:** Maps payment method codes to user-friendly icons, colors, and names.

**How it works:**
- Three helper methods for icon, color, and name
- Switch statements map codes to values
- Default cases handle unknown payment methods
- **Visual distinction**: Different colors for each method
- **User-friendly**: Converts 'cod' to "Cash on Delivery"

---

#### **Conditional Coupon Display**
```dart
if (order.couponCode != null) ...[
  const Text("Coupon Applied"),
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_offer, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              "${order.couponCode}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          order.couponType == 'percentage'
            ? "${order.couponValue?.toStringAsFixed(0)}% OFF"
            : "৳${order.couponValue?.toStringAsFixed(0)} OFF",
          style: const TextStyle(fontSize: 12, color: Colors.green),
        ),
      ],
    ),
  ),
  const SizedBox(height: 24),
]
```
**Purpose:** Displays applied coupon details if coupon was used.

**How it works:**
- Only shows if `order.couponCode != null`
- Green theme: background, border, text, icon
- Semi-transparent background (10% opacity)
- Shows coupon code and discount value
- Conditional formatting:
  - Percentage: "20% OFF"
  - Fixed: "৳50 OFF"
- Offer icon for visual recognition

---

#### **Order Items List with Product Images**
```dart
const Text("Order Items"),
const SizedBox(height: 12),
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
  ),
  child: Column(
    children: order.products.map((product) {
      final productData = productsProvider.findById(product.id);
      return Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                  image: productData?.imageUrl != null &&
                          productData!.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(productData.imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint('Error loading image: $exception');
                        },
                      )
                    : null,
                ),
                child: productData?.imageUrl == null ||
                        productData!.imageUrl.isEmpty
                  ? const Icon(Icons.shopping_bag, color: AppColors.primary, size: 20)
                  : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '৳${product.price.toStringAsFixed(0)} x ${product.quantity}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '৳${(product.price * product.quantity).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (order.products.indexOf(product) < order.products.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.grey.shade200),
            ),
        ],
      );
    }).toList(),
  ),
)
```
**Purpose:** Lists all products in the order with images, quantities, and prices.

**How it works:**
1. **Map Products**: Loops through order.products
2. **Fetch Product Data**: `productsProvider.findById()` gets full product info
3. **Product Image**: 
   - 50x50 container with rounded corners
   - Shows image if available
   - Falls back to shopping bag icon if image missing
   - `onError`: Handles image load failures gracefully
4. **Product Info**:
   - Name (max 2 lines with ellipsis)
   - Price x Quantity
   - Total (price × quantity)
5. **Layout**:
   - Image on left
   - Name and details in middle (Expanded)
   - Total on right
6. **Dividers**: Between items (except after last item)

**Bug Fix:** Uses actual product ID from cart instead of timestamp, fixing incorrect product display issue.

---

#### **Order Summary with Conditional Discount**
```dart
const Text("Order Summary"),
const SizedBox(height: 12),
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: [
      _buildSummaryRow("Subtotal", '৳${order.amount.toStringAsFixed(0)}'),
      if (order.couponCode != null)
        _buildSummaryRow(
          "Coupon Discount",
          order.couponType == 'percentage'
            ? "-${order.couponValue?.toStringAsFixed(0)}%"
            : "-৳${order.couponValue?.toStringAsFixed(0)}",
          isHighlight: true,
        ),
      const SizedBox(height: 8),
      _buildSummaryRow("Delivery Fee", "Free", isHighlight: true),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Divider(),
      ),
      _buildSummaryRow(
        "Total",
        '৳${order.amount.toStringAsFixed(0)}',
        isBold: true,
      ),
    ],
  ),
)
```
**Purpose:** Shows order cost breakdown including discounts.

**How it works:**
- Light background container
- Subtotal row
- Conditional coupon discount row (if coupon applied)
- Delivery fee (always free)
- Divider before total
- Total row (bold)
- `_buildSummaryRow()`: Helper for consistent formatting

---

#### **Summary Row Helper Widget**
```dart
Widget _buildSummaryRow(
  String label, 
  String value,
  {bool isBold = false, bool isHighlight = false}
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: isHighlight ? Colors.green : AppColors.textSecondary,
          fontSize: isBold ? 16 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: isHighlight ? Colors.green : AppColors.textPrimary,
          fontSize: isBold ? 16 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    ],
  );
}
```
**Purpose:** Creates consistent summary row styling with optional highlighting.

**How it works:**
- Row with space-between alignment
- `isBold`: Makes text larger and bolder (for total)
- `isHighlight`: Green color (for discounts and free delivery)
- Default: Grey label, dark value
- Reusable for all summary rows

---

## 5. Bug Fixes & Improvements

### Product ID Synchronization Fix

#### **Problem:**
Cart items were using timestamp-based IDs instead of actual Firestore product IDs, causing incorrect product display in order details.

#### **Solution in `lib/providers/cart_provider.dart`:**
```dart
void addItem(String productId, double price, String title) {
  if (_items.containsKey(productId)) {
    final existingItem = _items[productId]!;
    _items[productId] = CartItem(
      id: productId,  // Use actual product ID, not timestamp
      name: existingItem.name,
      quantity: existingItem.quantity + 1,
      price: existingItem.price,
    );
  } else {
    _items.putIfAbsent(
      productId,
      () => CartItem(
        id: productId,  // Use actual product ID
        name: title,
        quantity: 1,
        price: price,
      ),
    );
  }
  notifyListeners();
}
```
**How the fix works:**
- Changed CartItem ID from `DateTime.now().toString()` to `productId`
- Ensures cart items reference actual product documents
- Order details can now fetch correct product images and data
- Maintains cart functionality with proper product linking

---

### DropdownButton Value Mismatch Fix

#### **Problem:**
When editing a product with a category not in the current dropdown items list, the app would crash with "DropdownButton value not in items" error.

#### **Solution:**
```dart
Consumer<ProductsProvider>(
  builder: (context, productsProvider, child) {
    var categories = productsProvider.categories.toList();
    
    // Ensure selectedCategory exists in dropdown items
    if (!categories.contains(selectedCategory) && selectedCategory != "Other") {
      categories.add(selectedCategory);
      categories.sort();
    }
    
    return DropdownButton<String>(
      value: selectedCategory,
      items: [
        ...categories.map((cat) => DropdownMenuItem(
          value: cat,
          child: Text(cat),
        )),
        const DropdownMenuItem(value: "Other", child: Text("Other")),
      ],
    );
  },
)
```
**How the fix works:**
1. Gets current categories list
2. Checks if selectedCategory is in the list
3. If not (and not "Other"), adds it to the list
4. Sorts alphabetically
5. Ensures dropdown value always exists in items
6. Prevents crash from invalid dropdown value

---

### Provider Method Declaration Fix

#### **Problem:**
ProductsProvider had orphaned code and missing async method declarations for updateProduct and deleteProduct.

#### **Solution in `lib/providers/products_provider.dart`:**
```dart
Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
  try {
    await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .update(updates);
    
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = Product(
        id: productId,
        name: updates['name'] ?? _products[index].name,
        price: updates['price'] ?? _products[index].price,
        category: updates['category'] ?? _products[index].category,
        description: updates['description'] ?? _products[index].description,
        imageUrl: updates['imageUrl'] ?? _products[index].imageUrl,
      );
      notifyListeners();
    }
    
    await fetchCategories();
  } catch (e) {
    throw 'Failed to update product: $e';
  }
}

Future<void> deleteProduct(String productId) async {
  try {
    await FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .delete();
    
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
    
    await fetchCategories();
  } catch (e) {
    throw 'Failed to delete product: $e';
  }
}
```
**How the fix works:**
- Properly declares methods with `Future<void>` return type
- Uses `async` keyword for asynchronous operations
- Implements complete update and delete logic
- Updates both Firestore and local state
- Refreshes categories after changes
- Proper error handling with try-catch

---

## 6. Email Verification Auto-Refresh

### File: `lib/screens/main_screen.dart`

#### **App Lifecycle Management**
```dart
class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<AuthManager>(context, listen: false)
        .checkEmailVerificationStatus();
    }
  }
}
```
**Purpose:** Automatically checks email verification when user returns to app after verifying email.

**How it works:**
1. **WidgetsBindingObserver Mixin**: Allows listening to app lifecycle events
2. **initState**: Registers as observer
3. **dispose**: Unregisters observer to prevent memory leaks
4. **didChangeAppLifecycleState**: Called when app state changes
5. **AppLifecycleState.resumed**: Triggered when app comes to foreground
6. **Automatic Check**: When user returns from email app, verification status refreshes

**User Flow:**
1. User signs up
2. Verification email sent
3. User opens email app
4. Clicks verification link
5. Returns to app (app resumes)
6. Verification status automatically refreshes
7. User can now access app features

---

### File: `lib/providers/auth_provider.dart`

#### **Email Verification Check Method**
```dart
Future<bool> checkEmailVerificationStatus() async {
  if (_user != null) {
    try {
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      final isVerified = _user?.emailVerified ?? false;
      debugPrint('[AuthManager] Email verification status: $isVerified for ${_user?.email}');
      notifyListeners();
      return isVerified;
    } catch (e) {
      debugPrint('[AuthManager] Error checking email verification status: $e');
      return false;
    }
  }
  return false;
}
```
**Purpose:** Reloads user data from Firebase to get latest verification status.

**How it works:**
- `_user!.reload()`: Fetches latest user data from Firebase servers
- `FirebaseAuth.instance.currentUser`: Gets refreshed user object
- `emailVerified`: Boolean indicating verification status
- `notifyListeners()`: Updates UI if status changed
- Returns boolean for verification status
- Error handling prevents crashes

---

## Summary

This documentation covers Member 3's contributions including:

### Admin Panel Enhancement
- Product list with edit/delete actions
- Add new product dialog
- Form validation
- CRUD operations with Firestore

### Dynamic Category Management
- Dropdown populated from Firestore
- "Other" option for custom categories
- Safe value handling to prevent crashes
- Category persistence across app

### Product Edit Functionality
- Pre-populated form fields
- Same UI as add product
- Update existing products
- Proper async/await implementation

### Order Details Page
- Comprehensive order information display
- Customer details section
- Payment method with icons
- Coupon details (if applied)
- Order items with images
- Order summary with breakdown
- Date/time formatting
- Conditional rendering

### Bug Fixes
- Product ID synchronization in cart
- Dropdown value mismatch prevention
- Provider method declarations
- Orphaned code cleanup

### Email Verification Auto-Refresh
- App lifecycle monitoring
- Automatic verification check on resume
- Improved user experience

All implementations follow Flutter best practices with proper error handling, null safety, and user-friendly interfaces.
