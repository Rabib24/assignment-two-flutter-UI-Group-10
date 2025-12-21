# Member 1 - Technical Documentation: Widgets & Functions

**Focus Area:** Project Setup, Core Architecture, Authentication, and Basic E-commerce Flow

---

## Table of Contents
1. [Main Application Setup](#main-application-setup)
2. [Authentication Screens](#authentication-screens)
3. [Core Shopping Screens](#core-shopping-screens)
4. [State Management - Providers](#state-management-providers)
5. [Core UI Components](#core-ui-components)

---

## 1. Main Application Setup

### File: `lib/main.dart`

#### **WidgetsFlutterBinding.ensureInitialized()**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ...
}
```
**Purpose:** Ensures that Flutter's binding is initialized before any asynchronous operations. This is required when performing operations before `runApp()`, such as Firebase initialization.

**How it works:** This method initializes the Flutter framework's binding layer, which handles communication between the Flutter framework and the native platform. Without this, calling async methods or platform channels before `runApp()` would fail.

---

#### **Firebase.initializeApp()**
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);
```
**Purpose:** Initializes Firebase SDK for the current platform (Android/iOS/Web).

**How it works:** Connects the Flutter app to Firebase services using platform-specific configuration stored in `firebase_options.dart`. The `currentPlatform` automatically selects the correct configuration based on where the app is running.

---

#### **MultiProvider**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => AuthManager()),
    ChangeNotifierProvider(create: (_) => OrdersProvider()),
    ChangeNotifierProvider(create: (_) => ProductsProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => WishlistProvider()),
  ],
  child: Consumer<ThemeProvider>(...),
)
```
**Purpose:** Provides multiple state management providers to the entire widget tree using the Provider pattern.

**How it works:** 
- `MultiProvider` wraps all providers in a single widget to avoid nested ChangeNotifierProvider widgets
- Each provider is instantiated using `create: (_) => ProviderClass()`
- All descendant widgets can access these providers using `Provider.of<T>(context)` or `Consumer<T>`
- This implements the dependency injection pattern, making state accessible throughout the app

---

#### **Consumer<ThemeProvider>**
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      themeMode: themeProvider.themeMode,
      // ...
    );
  },
)
```
**Purpose:** Listens to ThemeProvider changes and rebuilds MaterialApp when theme changes.

**How it works:** Consumer widget automatically rebuilds when `notifyListeners()` is called in ThemeProvider. The `builder` function receives:
- `context`: Build context
- `themeProvider`: The current state of ThemeProvider
- `child`: Optional cached child widget that doesn't need rebuilding

---

#### **MaterialApp Configuration**
```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'MiniMart',
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeProvider.themeMode,
  home: const SplashScreen(),
  routes: {
    '/login': (context) => const LoginScreen(),
    '/signup': (context) => const SignupScreen(),
    // ...
  },
)
```
**Purpose:** Root widget that configures the entire app's navigation, theming, and initial route.

**How it works:**
- `theme` and `darkTheme`: Define light/dark mode themes
- `themeMode`: Controls which theme is active (light/dark/system)
- `home`: Initial screen shown on app launch
- `routes`: Named route table for navigation
- `onUnknownRoute`: Fallback for invalid routes

---

## 2. Authentication Screens

### File: `lib/auth/login_screen.dart`

#### **GlobalKey<FormState>**
```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(...)
)
```
**Purpose:** Provides a unique identifier for the Form widget, enabling validation and form state management.

**How it works:** GlobalKey allows accessing the FormState from anywhere to validate inputs, save form data, or reset the form. Call `_formKey.currentState!.validate()` to trigger validation on all TextFormField children.

---

#### **TextEditingController**
```dart
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```
**Purpose:** Manages the text input value and cursor position for TextField/TextFormField widgets.

**How it works:**
- Controllers read and write text programmatically: `_emailController.text`
- Must be disposed in the `dispose()` method to prevent memory leaks
- Attach to TextField using `controller` parameter

---

#### **TextFormField with Validator**
```dart
TextFormField(
  controller: _emailController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  },
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  // ...
)
```
**Purpose:** Input field with built-in validation logic.

**How it works:**
- `validator`: Function that returns error message (String) if invalid, or null if valid
- `keyboardType`: Optimizes keyboard layout for email input
- `textInputAction`: Configures keyboard "next" button behavior
- Validation triggered when `_formKey.currentState!.validate()` is called

---

#### **setState() for Loading State**
```dart
bool _isLoading = false;

setState(() {
  _isLoading = true;
});

// After async operation
setState(() {
  _isLoading = false;
});
```
**Purpose:** Updates widget state and triggers UI rebuild.

**How it works:** 
- `setState()` marks the widget as "dirty" and schedules a rebuild
- Use for updating local state like loading indicators, toggle states
- Only works in StatefulWidget classes

---

#### **Provider.of<AuthManager>(context, listen: false)**
```dart
await Provider.of<AuthManager>(context, listen: false)
    .signIn(email, password);
```
**Purpose:** Accesses AuthManager provider to call authentication methods.

**How it works:**
- `listen: false` means this widget won't rebuild when AuthManager changes
- Used when you only need to call methods, not read state
- The `await` keyword waits for the async signIn operation to complete

---

#### **ScaffoldMessenger.of(context).showSnackBar()**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(errorMessage),
    backgroundColor: Colors.red,
  ),
);
```
**Purpose:** Displays temporary notification message at the bottom of the screen.

**How it works:** ScaffoldMessenger manages the SnackBar queue, ensuring only one is shown at a time. The SnackBar automatically dismisses after a default duration (4 seconds) or custom duration.

---

#### **showDialog() with AlertDialog**
```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => AlertDialog(
    title: const Text("Email Not Verified"),
    content: const Text("Your email address has not been verified..."),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Cancel"),
      ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await _resendVerificationEmail(email, password);
        },
        child: const Text("Resend Email"),
      ),
    ],
  ),
);
```
**Purpose:** Displays a modal dialog box requiring user interaction.

**How it works:**
- `barrierDismissible: false`: User must tap a button; tapping outside won't close
- `builder`: Function that builds the dialog widget
- `AlertDialog`: Material Design dialog with title, content, and action buttons
- `TextButton` in actions: Interactive buttons to dismiss or perform actions
- `Navigator.pop(context)`: Closes the dialog

---

### File: `lib/auth/signup_screen.dart`

#### **Scaffold with AppBar**
```dart
Scaffold(
  backgroundColor: AppColors.surface,
  appBar: AppBar(
    backgroundColor: AppColors.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  body: SafeArea(...),
)
```
**Purpose:** Provides standard Material Design app structure with top app bar.

**How it works:**
- `appBar`: Top navigation bar with back button
- `elevation: 0`: Removes shadow under app bar
- `leading`: Left-side widget (back button)
- `Navigator.pop(context)`: Returns to previous screen

---

#### **SafeArea**
```dart
SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Column(...),
  ),
)
```
**Purpose:** Ensures content isn't obscured by device notches, status bars, or navigation bars.

**How it works:** Adds padding automatically to avoid system UI elements like the notch on iPhone X or Android navigation bar. Wraps content in safe viewing area.

---

#### **SingleChildScrollView**
```dart
SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 24.0),
  child: Column(
    children: [
      // Multiple input fields
    ],
  ),
)
```
**Purpose:** Makes content scrollable when it exceeds screen height.

**How it works:** Wraps content in a scrollable viewport. Essential for forms with many fields or when keyboard appears, preventing overflow errors. Only use with a single child (use Column to group multiple widgets).

---

#### **CircularProgressIndicator in Button**
```dart
ElevatedButton(
  onPressed: _isLoading ? null : () async { ... },
  child: _isLoading
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      )
    : const Text("Sign Up"),
)
```
**Purpose:** Displays loading spinner inside button while processing request.

**How it works:**
- Ternary operator checks `_isLoading` state
- If loading: shows CircularProgressIndicator
- If not loading: shows button text
- `onPressed: _isLoading ? null : ...`: Disables button when loading
- `valueColor`: Sets spinner color to white
- `strokeWidth`: Controls spinner line thickness

---

## 3. Core Shopping Screens

### File: `lib/screens/shop_page.dart`

#### **Consumer<ProductsProvider>**
```dart
Consumer<ProductsProvider>(
  builder: (context, productsData, child) {
    final products = productsData.products;
    final isLoading = productsData.isLoading;
    final errorMessage = productsData.errorMessage;
    // Build UI based on state
  },
)
```
**Purpose:** Listens to ProductsProvider changes and rebuilds when product data updates.

**How it works:**
- Automatically rebuilds when `notifyListeners()` is called in ProductsProvider
- Access provider state through `productsData` parameter
- Extract needed values: products list, loading state, errors

---

#### **WidgetsBinding.instance.addPostFrameCallback()**
```dart
if (!_hasLoadedProducts && products.isEmpty && !isLoading) {
  _hasLoadedProducts = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      productsData.fetchProducts();
    }
  });
}
```
**Purpose:** Schedules code to run after the current frame is rendered.

**How it works:**
- Ensures `fetchProducts()` is called after the widget tree is built
- Prevents "setState during build" errors
- `mounted` check prevents errors if widget is disposed before callback runs
- Used for initial data loading

---

#### **RefreshIndicator**
```dart
RefreshIndicator(
  onRefresh: () async {
    await Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).fetchProducts();
  },
  child: CustomScrollView(...),
)
```
**Purpose:** Enables pull-to-refresh gesture on scrollable content.

**How it works:**
- User pulls down on scrollable content
- `onRefresh` callback is triggered (must be async)
- Shows loading indicator until Future completes
- Commonly used to refresh data from server

---

#### **CustomScrollView with Slivers**
```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(
      child: Padding(...),
    ),
    SliverGrid(
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
  ],
)
```
**Purpose:** Creates advanced scrollable layouts with multiple scrollable sections.

**How it works:**
- `CustomScrollView`: Container for sliver widgets
- `SliverToBoxAdapter`: Wraps non-sliver widgets (search bar, banners)
- `SliverGrid`: Efficiently renders grid of items
- `SliverGridDelegateWithFixedCrossAxisCount`: Defines grid layout (2 columns)
- `childAspectRatio`: Controls item height/width ratio
- `SliverChildBuilderDelegate`: Builds items on-demand (lazy loading)

---

#### **PopupMenuButton for Sorting**
```dart
PopupMenuButton<String>(
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
)
```
**Purpose:** Displays a dropdown menu for sorting options.

**How it works:**
- `icon`: Widget shown before menu appears (sort icon)
- `itemBuilder`: Function that returns list of menu items
- `onSelected`: Callback when user selects an option
- Selected value updates `_sortBy` state, triggering product re-sort

---

#### **List Filtering and Sorting**
```dart
List<Product> filteredProducts = products;

if (_selectedCategory != 'All') {
  filteredProducts = filteredProducts
    .where((p) => p.category == _selectedCategory)
    .toList();
}

if (_searchQuery.isNotEmpty) {
  filteredProducts = filteredProducts
    .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
    .toList();
}

if (_sortBy == 'price_asc') {
  filteredProducts.sort((a, b) => a.price.compareTo(b.price));
} else if (_sortBy == 'price_desc') {
  filteredProducts.sort((a, b) => b.price.compareTo(a.price));
}
```
**Purpose:** Filters and sorts product list based on user selections.

**How it works:**
- Start with full products list
- Apply category filter using `where()` (returns items matching condition)
- Apply search filter checking if product name contains search query
- Sort using `sort()` method with custom comparator
- `compareTo()`: Returns -1, 0, or 1 for sorting

---

#### **PageView for Banners**
```dart
PageView(
  children: [
    _buildBanner(
      colors: [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
      icon: Icons.shopping_bag_outlined,
      title: "Summer Sale",
      subtitle: "Up to 50% OFF",
    ),
    _buildBanner(...),
    _buildBanner(...),
  ],
)
```
**Purpose:** Creates swipeable horizontal banner carousel.

**How it works:**
- PageView creates a scrollable list of full-screen pages
- User swipes left/right to navigate between banners
- Each child is a full-width promotional banner
- `_buildBanner()`: Custom method to build each banner with gradient

---

### File: `lib/screens/cart_page.dart`

#### **Consumer<CartProvider>**
```dart
Consumer<CartProvider>(
  builder: (context, cart, child) {
    final cartItems = cart.items.values.toList();
    return Column(...);
  },
)
```
**Purpose:** Listens to cart changes and rebuilds UI when items are added/removed.

**How it works:**
- `cart.items`: Map of product IDs to CartItem objects
- `.values.toList()`: Converts map values to a list for ListView
- Rebuilds automatically when cart changes

---

#### **ListView.builder**
```dart
ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: cart.items.length,
  itemBuilder: (context, index) {
    final item = cartItems[index];
    final productId = cart.items.keys.toList()[index];
    return CartItemWidget(productId: productId, item: item);
  },
)
```
**Purpose:** Efficiently builds a scrollable list of cart items.

**How it works:**
- `itemCount`: Number of items to build
- `itemBuilder`: Function called for each item
- Only builds visible items (lazy loading)
- `index`: Current item position (0-based)
- Returns CartItemWidget for each cart item

---

#### **Container with BoxShadow**
```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(30),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, -5),
      ),
    ],
  ),
  child: Column(...),
)
```
**Purpose:** Creates elevated card-like container with shadow and rounded corners.

**How it works:**
- `BoxDecoration`: Defines visual styling
- `borderRadius`: Rounds top corners only
- `boxShadow`: Creates shadow effect
- `blurRadius`: Softness of shadow
- `offset`: Shadow position (negative Y = shadow above)
- `withValues(alpha: 0.05)`: Sets shadow opacity to 5%

---

#### **Consumer2 for Multiple Providers**
```dart
Consumer2<CartProvider, OrdersProvider>(
  builder: (context, cart, orders, child) {
    return ElevatedButton(
      onPressed: cart.items.isEmpty ? null : () { ... },
      child: const Text("Checkout"),
    );
  },
)
```
**Purpose:** Listens to changes from two providers simultaneously.

**How it works:**
- Access both CartProvider and OrdersProvider in one widget
- `cart`: CartProvider instance
- `orders`: OrdersProvider instance
- Rebuilds when either provider calls `notifyListeners()`

---

#### **Navigator.of(context).push()**
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (ctx) => const CheckoutPage(),
  ),
);
```
**Purpose:** Navigates to a new screen with transition animation.

**How it works:**
- Pushes new route onto navigation stack
- `MaterialPageRoute`: Provides platform-specific transition (slide from right)
- `builder`: Creates the new page widget
- User can swipe back or tap back button to return

---

### File: `lib/screens/checkout_page.dart`

#### **Async initState() Data Loading**
```dart
@override
void initState() {
  super.initState();
  _loadUserData();
}

Future<void> _loadUserData() async {
  try {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final userData = authManager.userData;
    
    if (userData != null) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phoneNumber'] ?? '';
      });
    }
  } catch (e) {
    debugPrint('[CheckoutPage] Error loading user data: $e');
  }
}
```
**Purpose:** Pre-populates form fields with user data when page loads.

**How it works:**
- `initState()`: Called once when widget is inserted into tree
- Calls async method to fetch user data
- `listen: false`: Doesn't listen to provider changes
- Updates TextControllers with user data
- Try-catch handles potential errors gracefully

---

#### **Form Validation**
```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _nameController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Full Name') {
            if (value.length < 2) {
              return 'Please enter a valid name';
            }
          }
          return null;
        },
      ),
      // More fields...
    ],
  ),
)

// To validate:
if (_formKey.currentState!.validate()) {
  // Form is valid, proceed
}
```
**Purpose:** Validates all form fields before submission.

**How it works:**
- `Form` widget wraps all TextFormField widgets
- Each TextFormField has a `validator` function
- `_formKey.currentState!.validate()` triggers all validators
- Returns true if all validators return null (valid)
- Shows error messages for invalid fields

---

#### **RadioListTile for Payment Methods**
```dart
RadioListTile(
  value: 'cod',
  groupValue: _selectedPaymentMethod,
  onChanged: (value) {
    setState(() {
      _selectedPaymentMethod = value.toString();
    });
  },
  title: const Text("Cash on Delivery"),
  secondary: const Icon(Icons.money, color: Colors.green),
  activeColor: AppColors.primary,
)
```
**Purpose:** Creates a radio button selection in a list tile format.

**How it works:**
- `value`: This option's value
- `groupValue`: Currently selected value
- `onChanged`: Called when user selects this option
- Radio buttons with same `groupValue` are mutually exclusive
- Only one can be selected at a time
- `secondary`: Leading icon
- `activeColor`: Color when selected

---

#### **Conditional Rendering with Consumer**
```dart
Consumer<CartProvider>(
  builder: (context, cart, child) {
    if (cart.coupon != null) {
      return Container(
        // Show applied coupon
      );
    }
    
    return Row(
      // Show coupon input field
    );
  },
)
```
**Purpose:** Dynamically shows different UI based on state.

**How it works:**
- Check if coupon is applied
- If yes: Show applied coupon with remove button
- If no: Show input field with apply button
- UI updates automatically when cart state changes

---

#### **ElevatedButton with Async onPressed**
```dart
ElevatedButton(
  onPressed: _isLoading ? null : () async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await Future.delayed(const Duration(seconds: 2));
        await orders.addOrder(...);
        cart.clear();
        
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (ctx) => const OrderConfirmationPage(),
            ),
          );
        }
      } catch (e) {
        // Handle error
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  },
  child: _isLoading 
    ? const CircularProgressIndicator(color: Colors.white)
    : const Text("Place Order"),
)
```
**Purpose:** Handles complex async order placement with loading state.

**How it works:**
- Validates form before proceeding
- Sets loading state to show spinner
- `Future.delayed()`: Simulates processing time
- Calls provider method to save order
- Clears cart after successful order
- `context.mounted`: Checks if widget still exists before navigation
- `finally` block: Runs regardless of success/failure to reset loading state
- `Navigator.pushReplacement()`: Replaces current screen (can't go back)

---

### File: `lib/screens/orders_page.dart`

#### **Future.delayed with Duration.zero**
```dart
@override
void initState() {
  super.initState();
  Future.delayed(Duration.zero, () {
    if (mounted) {
      Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
    }
  });
}
```
**Purpose:** Safely calls provider method after widget is fully initialized.

**How it works:**
- `Duration.zero`: Schedules callback for next frame
- Avoids calling setState during build phase
- `mounted` check ensures widget exists before calling provider
- Alternative to `WidgetsBinding.instance.addPostFrameCallback()`

---

#### **Conditional Empty State UI**
```dart
Consumer<OrdersProvider>(
  builder: (context, orderData, child) {
    if (orderData.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No orders yet", style: TextStyle(...)),
          ],
        ),
      );
    }
    
    return ListView.builder(...);
  },
)
```
**Purpose:** Shows friendly message when no data exists.

**How it works:**
- Check if orders list is empty
- If empty: Show centered icon and message
- If not empty: Show list of orders
- Common pattern for better UX

---

## 4. State Management - Providers

### File: `lib/providers/auth_provider.dart`

#### **ChangeNotifier Mixin**
```dart
class AuthManager with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
}
```
**Purpose:** Makes the class observable, allowing widgets to listen for state changes.

**How it works:**
- `ChangeNotifier`: Mixin that provides `notifyListeners()` method
- Private variables (`_user`, `_userData`) store state
- Public getters expose state to widgets
- Call `notifyListeners()` after state changes to rebuild listeners

---

#### **Firebase Auth State Listener**
```dart
AuthManager() {
  _user = _auth.currentUser;
  _fetchUserData();
  
  _auth.authStateChanges().listen((User? user) {
    _user = user;
    if (user != null) {
      _fetchUserData();
    } else {
      _userData = null;
    }
    notifyListeners();
  });
}
```
**Purpose:** Automatically updates app state when user logs in/out.

**How it works:**
- Constructor initializes with current user
- `authStateChanges()`: Stream that emits when auth state changes
- `.listen()`: Subscribes to the stream
- Updates `_user` and fetches data when user logs in
- Clears data when user logs out
- `notifyListeners()`: Triggers UI rebuild

---

#### **Firestore Document Operations**
```dart
Future<void> _fetchUserData() async {
  if (_user != null) {
    try {
      final doc = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .get();
      _userData = doc.data();
      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint("Firebase error: ${e.code} - ${e.message}");
    }
  }
}
```
**Purpose:** Fetches user data from Firestore database.

**How it works:**
- `collection('users')`: Access users collection
- `.doc(_user!.uid)`: Get document by user ID
- `.get()`: Fetch document data
- `doc.data()`: Extract document data as Map
- Try-catch handles Firebase errors
- `notifyListeners()` updates UI with new data

---

#### **Firebase Auth Sign Up**
```dart
Future<void> signUp(String email, String password, String name, String phoneNumber) async {
  try {
    UserCredential userCredential = await _auth
      .createUserWithEmailAndPassword(email: email, password: password);
    
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    await userCredential.user!.sendEmailVerification();
    
    _user = userCredential.user;
    await _fetchUserData();
    notifyListeners();
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'An error occurred during sign up.';
    
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'This email is already registered.';
        break;
      case 'weak-password':
        errorMessage = 'The password is too weak.';
        break;
      // More cases...
    }
    
    throw errorMessage;
  }
}
```
**Purpose:** Creates new user account with email/password and stores user data.

**How it works:**
1. `createUserWithEmailAndPassword()`: Creates Firebase Auth account
2. `.set()`: Stores user profile in Firestore
3. `FieldValue.serverTimestamp()`: Server-side timestamp
4. `sendEmailVerification()`: Sends verification email
5. Updates local state with new user
6. Catches `FirebaseAuthException` for specific error handling
7. Switch statement maps error codes to user-friendly messages
8. Throws error message to be caught by UI

---

#### **Firebase Auth Sign In**
```dart
Future<void> signIn(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (!userCredential.user!.emailVerified) {
      await _auth.signOut();
      throw 'Email not verified. Please check your inbox...';
    }
    
    await _fetchUserData();
    _user = userCredential.user;
    notifyListeners();
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'An error occurred during sign in.';
    
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No account found with this email.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        break;
    }
    
    throw errorMessage;
  }
}
```
**Purpose:** Authenticates user with email and password.

**How it works:**
- `signInWithEmailAndPassword()`: Authenticates with Firebase
- Checks if email is verified
- If not verified: Signs out and throws error
- If verified: Fetches user data and updates state
- Error handling for common auth errors

---

#### **Firestore Update Operation**
```dart
Future<void> updateName(String newName) async {
  if (_user != null) {
    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': newName,
      });
      await _fetchUserData();
    } on FirebaseException catch (e) {
      throw 'Failed to update name: ${e.message ?? 'Unknown error'}';
    }
  } else {
    throw 'No user logged in';
  }
}
```
**Purpose:** Updates user's name in Firestore.

**How it works:**
- Checks if user is logged in
- `.update()`: Updates specific fields (vs `.set()` which replaces entire document)
- Re-fetches user data to update local state
- Catches Firebase errors and rethrows with message

---

### File: `lib/providers/cart_provider.dart`

#### **Map-Based State Management**
```dart
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  
  Map<String, CartItem> get items => _items;
  
  int get itemCount => _items.length;
}
```
**Purpose:** Stores cart items using product ID as key for efficient lookups.

**How it works:**
- Map structure: `{productId: CartItem}`
- Direct access by ID: `_items[productId]`
- Easy to check if product exists: `_items.containsKey(productId)`
- Get all items: `_items.values.toList()`

---

#### **Computed Getter**
```dart
double get totalAmount {
  var total = 0.0;
  _items.forEach((key, cartItem) {
    total += cartItem.price * cartItem.quantity;
  });
  
  if (_coupon != null) {
    if (_coupon!.discountType == 'percentage') {
      total = total * (1 - (_coupon!.discountValue / 100));
    } else {
      total = total - _coupon!.discountValue;
    }
  }
  
  return total < 0 ? 0 : total;
}
```
**Purpose:** Calculates cart total dynamically, including coupon discounts.

**How it works:**
- Computed property (no stored value)
- Loops through all cart items
- Sums price × quantity for each item
- Applies coupon discount if exists
- Percentage: Multiply by (1 - percentage/100)
- Fixed: Subtract discount amount
- Ensures total never goes negative

---

#### **Add Item Logic**
```dart
void addItem(String productId, double price, String title) {
  if (_items.containsKey(productId)) {
    final existingItem = _items[productId]!;
    _items[productId] = CartItem(
      id: existingItem.id,
      name: existingItem.name,
      quantity: existingItem.quantity + 1,
      price: existingItem.price,
    );
  } else {
    _items.putIfAbsent(
      productId,
      () => CartItem(
        id: productId,
        name: title,
        quantity: 1,
        price: price,
      ),
    );
  }
  notifyListeners();
}
```
**Purpose:** Adds item to cart or increments quantity if already exists.

**How it works:**
- Checks if product already in cart
- If yes: Creates new CartItem with quantity+1
- If no: Adds new item with quantity 1
- `putIfAbsent()`: Only adds if key doesn't exist
- `notifyListeners()`: Updates UI

---

#### **Firestore Coupon Query**
```dart
Future<void> applyCoupon(String code) async {
  try {
    final snapshot = await FirebaseFirestore.instance
      .collection('coupons')
      .where('code', isEqualTo: code)
      .get();
    
    if (snapshot.docs.isEmpty) {
      throw "Invalid coupon code";
    }
    
    final coupon = Coupon.fromFirestore(snapshot.docs.first);
    if (!coupon.isValid) {
      throw "Coupon has expired";
    }
    
    _coupon = coupon;
    notifyListeners();
  } catch (e) {
    throw e.toString();
  }
}
```
**Purpose:** Validates and applies coupon code.

**How it works:**
- `.where()`: Queries Firestore for matching coupon code
- `.get()`: Executes query
- Checks if any documents match
- Converts document to Coupon object
- Validates coupon expiry
- Updates state with coupon
- Throws error if invalid

---

### File: `lib/providers/orders_provider.dart`

#### **Order Placement**
```dart
Future<void> addOrder(
  List<CartItem> cartProducts,
  double total,
  String customerName,
  String customerPhone,
  String customerAddress,
  String paymentMethod,
  String? couponCode,
  String? couponType,
  double? couponValue,
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'User not logged in';
    
    final timestamp = DateTime.now();
    final orderRef = await FirebaseFirestore.instance
      .collection('orders')
      .add({
        'amount': total,
        'dateTime': timestamp,
        'products': cartProducts.map((cp) => {
          'id': cp.id,
          'name': cp.name,
          'quantity': cp.quantity,
          'price': cp.price,
        }).toList(),
        'userId': user.uid,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'paymentMethod': paymentMethod,
        'status': 'Pending',
        'couponCode': couponCode,
        'couponType': couponType,
        'couponValue': couponValue,
      });
    
    _orders.insert(0, OrderItem(
      id: orderRef.id,
      amount: total,
      products: cartProducts,
      dateTime: timestamp,
      // ... other fields
    ));
    
    notifyListeners();
  } catch (e) {
    throw 'Failed to place order: $e';
  }
}
```
**Purpose:** Creates new order in Firestore and updates local state.

**How it works:**
- Validates user is logged in
- `.add()`: Creates new document with auto-generated ID
- Maps CartItem objects to plain maps for Firestore
- Stores all order details including customer info, payment method, coupon
- `.insert(0, ...)`: Adds new order to start of local list
- Returns `orderRef` with generated document ID

---

## 5. Core UI Components

### File: `lib/widgets/splash_screen.dart`

#### **AnimationController**
```dart
late AnimationController _controller;

@override
void initState() {
  super.initState();
  
  _controller = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
}

@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```
**Purpose:** Controls animation timing and lifecycle.

**How it works:**
- `late`: Initialized in initState()
- `duration`: Total animation duration
- `vsync: this`: Synchronizes animation with screen refresh (requires `TickerProviderStateMixin`)
- Must be disposed to prevent memory leaks

---

#### **Tween Animations**
```dart
_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
  ),
);

_scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
  ),
);
```
**Purpose:** Defines animation value ranges and curves.

**How it works:**
- `Tween`: Defines start and end values
- `.animate()`: Connects tween to controller
- `CurvedAnimation`: Applies easing curve
- `Interval`: Defines when animation runs (0.0-1.0 of total duration)
- `Curves.easeOut`: Slows down at the end

---

#### **AnimatedBuilder**
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(...),
      ),
    );
  },
)
```
**Purpose:** Rebuilds widget tree as animation progresses.

**How it works:**
- Listens to `_controller` updates
- `builder`: Called on each animation frame
- Access animation values: `_scaleAnimation.value`
- Combines multiple animations: scale and fade
- Efficient: Only rebuilds this subtree

---

#### **FadeTransition**
```dart
FadeTransition(
  opacity: _fadeAnimation,
  child: Column(
    children: [
      const Text('MiniMart'),
      // ...
    ],
  ),
)
```
**Purpose:** Animates widget opacity (fade in/out).

**How it works:**
- Takes Animation<double> for opacity (0.0-1.0)
- Automatically rebuilds as animation value changes
- More efficient than AnimatedBuilder for simple opacity changes

---

#### **PageRouteBuilder for Custom Transitions**
```dart
Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destination,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 600),
  ),
);
```
**Purpose:** Creates custom page transition animation.

**How it works:**
- `pageBuilder`: Returns the destination widget
- `transitionsBuilder`: Defines how transition looks
- `animation`: Goes from 0.0 to 1.0 during transition
- `FadeTransition`: Fades in new page
- `transitionDuration`: How long transition takes
- `pushReplacement`: Removes splash screen from stack

---

### File: `lib/widgets/app_drawer.dart`

#### **Drawer Widget**
```dart
Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(...),
      ListTile(...),
      const Divider(),
      // More items
    ],
  ),
)
```
**Purpose:** Side navigation menu that slides in from left.

**How it works:**
- Automatically managed by Scaffold
- Opens when hamburger icon tapped
- `ListView` with `padding: EdgeInsets.zero`: Removes default padding
- `DrawerHeader`: Top section with user info
- `ListTile`: Navigation menu items
- `Divider`: Visual separator

---

#### **Async Sign Out**
```dart
ListTile(
  leading: const Icon(Icons.logout, color: Colors.red),
  title: const Text('Logout'),
  onTap: () async {
    try {
      await Provider.of<AuthManager>(context, listen: false).signOut();
      if (context.mounted) {
        Navigator.pop(context); // Close drawer
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  },
)
```
**Purpose:** Signs out user and navigates to login screen.

**How it works:**
- `await signOut()`: Waits for sign out to complete
- `context.mounted`: Checks widget still exists after async operation
- `Navigator.pop()`: Closes drawer
- `pushNamedAndRemoveUntil()`: Navigates to login and clears navigation stack
- `(route) => false`: Removes all previous routes
- Try-catch handles errors gracefully

---

### File: `lib/widgets/product_grid_item.dart`

#### **GestureDetector for Navigation**
```dart
GestureDetector(
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ProductDetailsPage(product: product),
      ),
    );
  },
  child: Container(...),
)
```
**Purpose:** Makes entire product card tappable to view details.

**How it works:**
- Wraps entire card widget
- `onTap`: Callback when user taps anywhere on card
- Navigates to product details page
- Passes product data to details page

---

#### **Stack for Overlapping Widgets**
```dart
Stack(
  fit: StackFit.expand,
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
      ),
    ),
    Positioned(
      top: 8,
      right: 8,
      child: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          // Heart icon
        },
      ),
    ),
  ],
)
```
**Purpose:** Overlays wishlist heart icon on product image.

**How it works:**
- `Stack`: Overlaps children (like layers)
- `StackFit.expand`: Makes children fill available space
- First child: Product image (bottom layer)
- `Positioned`: Places widget at specific position
- `top: 8, right: 8`: 8px from top-right corner
- Second child: Heart icon (top layer)

---

#### **ClipRRect for Rounded Images**
```dart
ClipRRect(
  borderRadius: const BorderRadius.vertical(
    top: Radius.circular(15),
  ),
  child: Image.network(
    product.imageUrl,
    fit: BoxFit.cover,
  ),
)
```
**Purpose:** Clips image to have rounded corners.

**How it works:**
- `ClipRRect`: Clips child widget with rounded corners
- `BorderRadius.vertical`: Only rounds top corners
- `fit: BoxFit.cover`: Scales image to fill space, cropping if needed
- Prevents image from overflowing rounded container

---

#### **Conditional Widget Rendering**
```dart
Consumer<CartProvider>(
  builder: (context, cart, child) {
    final cartItem = cart.items[product.id];
    final isInCart = cartItem != null;
    final quantity = cartItem?.quantity ?? 0;
    
    return isInCart
      ? Row(
          // Show quantity controls
        )
      : ElevatedButton(
          // Show "Add to Cart" button
        );
  },
)
```
**Purpose:** Shows different UI based on whether product is in cart.

**How it works:**
- Checks if product exists in cart
- If in cart: Shows increment/decrement buttons with quantity
- If not in cart: Shows "Add to Cart" button
- Ternary operator for concise conditional rendering
- `?.quantity ?? 0`: Safe navigation with default value

---

#### **SnackBar with Action**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("${product.name} added to cart!"),
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: 'UNDO',
      onPressed: () {
        cart.removeSingleItem(product.id);
      },
    ),
  ),
);
```
**Purpose:** Shows notification with undo action when adding to cart.

**How it works:**
- `content`: Message text
- `duration`: Auto-dismiss time
- `action`: Interactive button in snackbar
- User can undo add by tapping "UNDO"
- Removes item from cart if undone

---

### File: `lib/screens/product_details_page.dart`

#### **SliverAppBar with Expandable Image**
```dart
SliverAppBar(
  expandedHeight: 300,
  pinned: true,
  backgroundColor: AppColors.surface,
  flexibleSpace: FlexibleSpaceBar(
    background: Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
    ),
  ),
)
```
**Purpose:** Creates app bar that expands/collapses with scroll, showing product image.

**How it works:**
- Must be inside CustomScrollView
- `expandedHeight`: Height when fully expanded
- `pinned: true`: App bar stays visible when scrolled up
- `FlexibleSpaceBar`: Content that changes size with scroll
- `background`: Widget shown when expanded (product image)
- Image shrinks as user scrolls down

---

#### **bottomSheet for Fixed Button**
```dart
bottomSheet: Container(
  padding: const EdgeInsets.all(24),
  child: SafeArea(
    child: ElevatedButton(
      onPressed: () {
        // Add/Remove from cart
      },
      child: Text(
        isInCart ? "Remove from Cart" : "Add to Cart",
      ),
    ),
  ),
)
```
**Purpose:** Displays fixed "Add to Cart" button at screen bottom.

**How it works:**
- `bottomSheet`: Scaffold property for persistent bottom content
- Unlike `bottomNavigationBar`, can have custom content
- `SafeArea`: Ensures button not obscured by device notches
- Button text changes based on cart status

---

## Summary

This documentation covers Member 1's core contributions including:
- **Project Setup**: Firebase initialization, Provider architecture
- **Authentication Flow**: Sign up, sign in, email verification
- **Product Catalog**: Fetching and displaying products
- **Cart System**: Add/remove items, quantity management
- **Checkout Process**: Form validation, payment selection, order placement
- **Order History**: Viewing past orders
- **Navigation & UI**: Splash screen, drawer, bottom navigation

All widgets and functions are explained with their purpose and implementation details, enabling team members to confidently explain functionality during technical questioning.
