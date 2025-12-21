# Member 2 - Technical Documentation: Widgets & Functions

**Focus Area:** User Experience Enhancements - Search, Sorting, Dark Mode, and Wishlist Features

---

## Table of Contents
1. [Search Functionality](#search-functionality)
2. [Sorting System](#sorting-system)
3. [Dark Mode Implementation](#dark-mode-implementation)
4. [Wishlist System](#wishlist-system)
5. [Theme Provider](#theme-provider)
6. [Profile Page Enhancements](#profile-page-enhancements)

---

## 1. Search Functionality

### File: `lib/screens/shop_page.dart`

#### **TextEditingController for Search**
```dart
final TextEditingController _searchController = TextEditingController();
String _searchQuery = "";

@override
void initState() {
  super.initState();
  _searchController.addListener(_debounceSearch);
}

@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}
```
**Purpose:** Manages search input text and listens for changes to trigger search filtering.

**How it works:**
- `TextEditingController`: Manages text field input value
- `addListener()`: Attaches callback function that runs whenever text changes
- `_debounceSearch`: Custom method to delay search execution
- Must dispose controller to free memory when widget is destroyed

---

#### **Debounced Search Implementation**
```dart
late Future<void> _searchDebounce;

void _debounceSearch() async {
  await _searchDebounce;
  
  _searchDebounce = Future.delayed(const Duration(milliseconds: 300), () {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  });
}
```
**Purpose:** Delays search execution to avoid excessive filtering on every keystroke, improving performance.

**How it works:**
- Waits for previous debounce Future to complete (cancels previous delay)
- Creates new Future with 300ms delay
- After delay, updates `_searchQuery` state
- `mounted` check: Ensures widget still exists before calling setState
- **Performance benefit**: Only searches after user stops typing for 300ms, reducing unnecessary computation

---

#### **Search TextField with prefixIcon**
```dart
TextField(
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
)
```
**Purpose:** Creates visually appealing search input field with search icon.

**How it works:**
- `prefixIcon`: Icon displayed at the start of the text field (magnifying glass)
- `hintText`: Placeholder text shown when field is empty
- `filled: true`: Adds background color to text field
- `fillColor`: Background color of the field
- `borderSide: BorderSide.none`: Removes border outline
- `borderRadius`: Rounds corners for modern look

---

#### **Search Filtering Logic**
```dart
List<Product> filteredProducts = products;

if (_searchQuery.isNotEmpty) {
  filteredProducts = filteredProducts.where((p) => 
    p.name.toLowerCase().contains(_searchQuery.toLowerCase())
  ).toList();
}
```
**Purpose:** Filters product list based on search query, case-insensitive.

**How it works:**
- Starts with full product list
- `.where()`: Filters elements matching the condition
- `toLowerCase()`: Converts both product name and search query to lowercase
- `.contains()`: Checks if product name contains search text
- **Case-insensitive**: "APPLE" matches "apple", "Apple", "aPpLe"
- `.toList()`: Converts filtered iterable back to list

---

## 2. Sorting System

### File: `lib/screens/shop_page.dart`

#### **Sort State Management**
```dart
String _sortBy = 'default'; // default, price_asc, price_desc

setState(() {
  _sortBy = value;
});
```
**Purpose:** Tracks current sort option selected by user.

**How it works:**
- String variable stores sort mode: 'default', 'price_asc', 'price_desc'
- When user selects option, setState updates value and triggers rebuild
- UI responds to show sorted products

---

#### **PopupMenuButton for Sort Options**
```dart
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
)
```
**Purpose:** Displays dropdown menu with sorting options when user taps sort icon.

**How it works:**
- `PopupMenuButton<String>`: Generic type specifies value type (String)
- `icon`: Widget shown before menu opens (sort icon)
- `itemBuilder`: Function returning list of menu options
- `PopupMenuItem`: Each menu option with value and display text
- `onSelected`: Callback when user selects option
- Selected value updates `_sortBy` state, triggering product re-sort

---

#### **Product Sorting Logic**
```dart
if (_sortBy == 'price_asc') {
  filteredProducts.sort((a, b) => a.price.compareTo(b.price));
} else if (_sortBy == 'price_desc') {
  filteredProducts.sort((a, b) => b.price.compareTo(a.price));
}
```
**Purpose:** Sorts product list by price in ascending or descending order.

**How it works:**
- `sort()`: In-place sorting method on List
- Takes comparator function: `(a, b) => ...`
- `compareTo()`: Returns -1, 0, or 1 for sorting
- **Ascending**: `a.compareTo(b)` - lower prices first
- **Descending**: `b.compareTo(a)` - higher prices first
- Modifies `filteredProducts` list directly

---

#### **Conditional Banner Display**
```dart
final bool isSearchingOrSorting = _searchQuery.isNotEmpty || 
                                  _sortBy != 'default' || 
                                  _selectedCategory != 'All';

if (!isSearchingOrSorting) ...[
  const SizedBox(height: 20),
  SizedBox(
    height: 180,
    child: PageView(
      children: [
        _buildBanner(...),
        _buildBanner(...),
        _buildBanner(...),
      ],
    ),
  ),
]
```
**Purpose:** Hides promotional banners when user is actively searching, sorting, or filtering.

**How it works:**
- `isSearchingOrSorting`: Boolean flag checking if any filter/sort is active
- Spread operator `...[]`: Conditionally adds widgets to list
- If false (not searching): Shows banner carousel
- If true: Skips banner widgets entirely
- **UX improvement**: More space for search results, cleaner interface

---

## 3. Dark Mode Implementation

### File: `lib/providers/theme_provider.dart`

#### **ThemeProvider with ChangeNotifier**
```dart
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadTheme();
  }
}
```
**Purpose:** Manages app-wide theme state (light/dark mode) with persistence.

**How it works:**
- `ChangeNotifier`: Enables widgets to listen for theme changes
- `ThemeMode`: Flutter enum with values: light, dark, system
- `isDarkMode`: Convenient boolean getter for checking dark mode
- Constructor calls `_loadTheme()` to restore saved preference on app start

---

#### **SharedPreferences for Theme Persistence**
```dart
void _loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode');
  if (isDark != null) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
```
**Purpose:** Loads saved theme preference from device storage on app launch.

**How it works:**
- `SharedPreferences`: Key-value storage for simple data persistence
- `getInstance()`: Gets SharedPreferences instance (async)
- `getBool('isDarkMode')`: Retrieves saved boolean value
- If saved value exists: Updates `_themeMode` and notifies listeners
- **Persistence**: User's theme choice survives app restarts

---

#### **Toggle Theme with Save**
```dart
void toggleTheme(bool isDark) async {
  _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  notifyListeners();
  
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isDarkMode', isDark);
}
```
**Purpose:** Changes theme and saves preference to device storage.

**How it works:**
1. Updates `_themeMode` immediately
2. `notifyListeners()`: Triggers UI rebuild with new theme
3. Gets SharedPreferences instance
4. `setBool()`: Saves theme preference
5. **Two-step process**: UI updates instantly, saving happens in background

---

### File: `lib/screens/profile_page.dart`

#### **SwitchListTile for Dark Mode Toggle**
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return SwitchListTile(
      secondary: Icon(
        themeProvider.isDarkMode
          ? Icons.dark_mode_outlined
          : Icons.light_mode_outlined,
        color: const Color(0xFF636E72),
      ),
      title: const Text("Dark Mode"),
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.toggleTheme(value);
      },
      activeThumbColor: AppColors.primary,
    );
  },
)
```
**Purpose:** Displays switch control for toggling dark mode in settings.

**How it works:**
- `Consumer<ThemeProvider>`: Rebuilds when theme changes
- `SwitchListTile`: Combines ListTile with Switch widget
- `secondary`: Leading widget (icon that changes based on theme)
- `value`: Current switch state (on/off)
- `onChanged`: Callback when user toggles switch
- `activeThumbColor`: Color of switch thumb when enabled
- **Dynamic icon**: Shows moon when dark mode on, sun when off

---

### File: `lib/theme/app_theme.dart`

#### **Light and Dark Theme Definitions**
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    // More theme properties...
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    // Dark theme properties...
  );
}
```
**Purpose:** Defines consistent styling for entire app in both light and dark modes.

**How it works:**
- `ThemeData`: Container for all theme properties
- `useMaterial3: true`: Enables Material Design 3 components
- `brightness`: Determines light or dark theme base
- `ColorScheme.fromSeed()`: Generates harmonious color palette from primary color
- `scaffoldBackgroundColor`: Default background for all screens
- `appBarTheme`: Customizes all AppBars throughout app
- **Consistency**: All widgets automatically use theme colors

---

#### **Consumer in MaterialApp**
```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // ...
    );
  },
)
```
**Purpose:** Applies theme to entire app and rebuilds when theme changes.

**How it works:**
- `theme`: Applied when ThemeMode is light
- `darkTheme`: Applied when ThemeMode is dark
- `themeMode`: Current active mode from ThemeProvider
- When user toggles theme:
  1. ThemeProvider updates `_themeMode`
  2. Calls `notifyListeners()`
  3. Consumer rebuilds MaterialApp
  4. Entire app switches theme instantly

---

## 4. Wishlist System

### File: `lib/providers/wishlist_provider.dart`

#### **WishlistProvider with Firestore Integration**
```dart
class WishlistProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _wishlistIds = [];
  
  List<String> get wishlistIds => _wishlistIds;
  
  WishlistProvider() {
    _fetchWishlist();
  }
}
```
**Purpose:** Manages user's wishlist items with cloud synchronization.

**How it works:**
- Stores only product IDs (not full product objects) to minimize data
- Connects to Firebase Auth to get current user
- Connects to Firestore to persist wishlist
- Constructor calls `_fetchWishlist()` to load saved wishlist on app start

---

#### **Fetch Wishlist from Firestore**
```dart
Future<void> _fetchWishlist() async {
  final user = _auth.currentUser;
  if (user == null) return;
  
  try {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('wishlist')) {
        _wishlistIds = List<String>.from(data['wishlist']);
        notifyListeners();
      }
    }
  } catch (e) {
    debugPrint("Error fetching wishlist: $e");
  }
}
```
**Purpose:** Loads user's saved wishlist from Firestore database.

**How it works:**
- Gets currently logged-in user
- Returns early if no user (guest mode)
- Fetches user document from Firestore
- Checks if document exists and contains 'wishlist' field
- `List<String>.from()`: Converts Firestore array to Dart List
- Updates local state and notifies listeners
- Handles errors gracefully with try-catch

---

#### **Check if Product in Wishlist**
```dart
bool isInWishlist(String productId) {
  return _wishlistIds.contains(productId);
}
```
**Purpose:** Quick check if a product is in user's wishlist.

**How it works:**
- `contains()`: Checks if productId exists in list
- Returns boolean: true if in wishlist, false otherwise
- Used by UI to show filled vs outlined heart icon

---

#### **Toggle Wishlist with Optimistic Update**
```dart
Future<void> toggleWishlist(String productId) async {
  final user = _auth.currentUser;
  if (user == null) return;
  
  try {
    // Optimistic update: Update UI immediately
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
    
    // Persist to Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'wishlist': _wishlistIds,
    }, SetOptions(merge: true));
  } catch (e) {
    debugPrint("Error updating wishlist: $e");
    
    // Revert on error
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }
}
```
**Purpose:** Adds/removes product from wishlist with instant UI feedback and cloud sync.

**How it works:**
1. **Optimistic Update**: 
   - Immediately updates local state
   - UI responds instantly (no waiting for server)
2. **Firestore Update**:
   - `.set()` with `SetOptions(merge: true)`: Updates wishlist field without overwriting other user data
3. **Error Handling**:
   - If Firestore update fails, reverts local change
   - User sees accurate state even on network failure
4. **UX Benefit**: Instant feedback makes app feel faster

---

### File: `lib/widgets/product_grid_item.dart`

#### **Positioned Heart Icon**
```dart
Positioned(
  top: 8,
  right: 8,
  child: Consumer<WishlistProvider>(
    builder: (context, wishlist, child) {
      final isFavorite = wishlist.isInWishlist(product.id);
      return GestureDetector(
        onTap: () => wishlist.toggleWishlist(product.id),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isFavorite ? const Color(0xFFFF6B6B) : Colors.grey,
          ),
        ),
      );
    },
  ),
)
```
**Purpose:** Displays interactive heart icon on product cards for adding/removing from wishlist.

**How it works:**
- `Positioned`: Places icon in top-right corner of product image
- `Consumer<WishlistProvider>`: Listens for wishlist changes
- `isInWishlist()`: Checks if product is favorited
- `GestureDetector`: Makes icon tappable
- `toggleWishlist()`: Adds/removes product on tap
- **Visual feedback**:
  - Filled heart (red) when in wishlist
  - Outlined heart (grey) when not in wishlist
- Circular white container with shadow for contrast against any image

---

### File: `lib/screens/wishlist_page.dart`

#### **WishlistPage with Consumer2**
```dart
Scaffold(
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
      
      return GridView.builder(...);
    },
  ),
)
```
**Purpose:** Displays user's wishlist items in a grid layout.

**How it works:**
- `Consumer2`: Listens to both WishlistProvider and ProductsProvider
- **Data joining**:
  - Gets list of wishlist product IDs
  - Gets all products from catalog
  - Filters products matching wishlist IDs
- **Empty state**: Shows friendly message when no favorites
- **Grid view**: Reuses ProductGridItem for consistent UI

---

#### **GridView.builder for Wishlist Display**
```dart
GridView.builder(
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
)
```
**Purpose:** Efficiently renders wishlist products in a 2-column grid.

**How it works:**
- `GridView.builder`: Lazy-loads items (builds only visible items)
- `gridDelegate`: Defines grid layout:
  - `crossAxisCount: 2`: Two columns
  - `childAspectRatio: 0.75`: Height = width × 0.75
  - `mainSpacing/crossSpacing`: Gap between items
- `itemBuilder`: Creates ProductGridItem for each product
- Reuses existing product card component

---

## 5. Theme Provider

### File: `lib/providers/theme_provider.dart`

#### **ThemeMode Enum Values**
```dart
ThemeMode _themeMode = ThemeMode.system;

// ThemeMode options:
// - ThemeMode.light: Always light theme
// - ThemeMode.dark: Always dark theme
// - ThemeMode.system: Follows device setting
```
**Purpose:** Provides three theme options: light, dark, or follow system.

**How it works:**
- `ThemeMode.system`: Automatically switches based on device dark mode setting
- `ThemeMode.light`: Forces light theme regardless of device setting
- `ThemeMode.dark`: Forces dark theme regardless of device setting
- Default to system for better OS integration

---

#### **Getter Methods**
```dart
ThemeMode get themeMode => _themeMode;

bool get isDarkMode => _themeMode == ThemeMode.dark;
```
**Purpose:** Provides clean access to theme state for widgets.

**How it works:**
- `themeMode`: Returns current ThemeMode enum value
- `isDarkMode`: Boolean convenience getter
- Used by widgets to check theme and update UI
- Example: Changing icon based on theme

---

## 6. Profile Page Enhancements

### File: `lib/screens/profile_page.dart`

#### **Theme Toggle in Profile**
```dart
Container(
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
  child: Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return SwitchListTile(
        secondary: Icon(
          themeProvider.isDarkMode
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined,
          color: const Color(0xFF636E72),
        ),
        title: const Text("Dark Mode"),
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme(value);
        },
        activeThumbColor: AppColors.primary,
      );
    },
  ),
)
```
**Purpose:** Provides accessible theme toggle in user profile settings.

**How it works:**
- Wrapped in styled container with shadow and rounded corners
- Consumer rebuilds only this widget when theme changes
- Icon changes based on current theme (moon/sun)
- Switch value reflects current theme state
- Tapping switch calls `toggleTheme()`
- Active color uses app primary color for branding

---

#### **Navigation to Admin Panel**
```dart
Container(
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
  child: ListTile(
    leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
    title: const Text("Admin Panel"),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
    },
  ),
)
```
**Purpose:** Provides navigation to admin panel from profile page.

**How it works:**
- ListTile wrapped in decorated container
- Purple admin icon for visual distinction
- Arrow icon indicates it's a navigation action
- `Navigator.push()`: Opens admin page
- Keeps profile page in navigation stack (can go back)

---

## Advanced Search & Filtering

### File: `lib/screens/shop_page.dart`

#### **Category Dropdown Filter**
```dart
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
)
```
**Purpose:** Allows users to filter products by category using dropdown menu.

**How it works:**
- `DropdownButtonHideUnderline`: Removes default underline
- `isExpanded: true`: Dropdown fills container width
- `_getUniqueCategories()`: Dynamically generates category list from products
- `onChanged`: Updates selected category and triggers filter
- Works alongside search and sort for combined filtering

---

#### **Get Unique Categories Helper**
```dart
List<String> _getUniqueCategories(List<Product> products) {
  final categories = {'All'};
  for (final product in products) {
    if (product.category.isNotEmpty) {
      categories.add(product.category);
    }
  }
  return categories.toList()..sort();
}
```
**Purpose:** Extracts unique category names from product list.

**How it works:**
- Uses `Set` to automatically remove duplicates
- Starts with 'All' option
- Loops through all products
- Adds each category if not empty
- Converts to list and sorts alphabetically
- `..sort()`: Cascade notation to sort and return list

---

#### **Combined Filter Logic**
```dart
List<Product> filteredProducts = products;

// Apply category filter
if (_selectedCategory != 'All') {
  filteredProducts = filteredProducts
    .where((p) => p.category == _selectedCategory)
    .toList();
}

// Apply search filter
if (_searchQuery.isNotEmpty) {
  filteredProducts = filteredProducts
    .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
    .toList();
}

// Apply sorting
if (_sortBy == 'price_asc') {
  filteredProducts.sort((a, b) => a.price.compareTo(b.price));
} else if (_sortBy == 'price_desc') {
  filteredProducts.sort((a, b) => b.price.compareTo(a.price));
}
```
**Purpose:** Applies multiple filters and sorting in sequence.

**How it works:**
1. Start with all products
2. Apply category filter (if not 'All')
3. Apply search filter (if search query exists)
4. Apply sorting (if not 'default')
5. Each filter refines the previous result
6. **Order matters**: Category → Search → Sort
7. Final list contains only products matching all criteria

---

## UI Polish & User Experience

### Gradient Banners with PageView

#### **Custom Banner Builder**
```dart
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
```
**Purpose:** Creates visually appealing promotional banner cards.

**How it works:**
- **LinearGradient**: Smooth color transition from top-left to bottom-right
- **BoxShadow**: Colored shadow matching gradient for depth
- **Stack**: Layers background icon and text
- **Positioned icon**: Partially off-screen for modern design
- **Semi-transparent icon**: `alpha: 0.2` for subtle background effect
- **Reusable**: Different colors/icons for various promotions

---

### Responsive Grid Layout

#### **SliverGridDelegateWithFixedCrossAxisCount**
```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  childAspectRatio: 0.75,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
)
```
**Purpose:** Defines consistent grid layout for product cards.

**How it works:**
- `crossAxisCount: 2`: Fixed 2 columns on all screen sizes
- `childAspectRatio: 0.75`: 
  - Width:Height ratio
  - If width = 100, height = 133
  - Taller cards for better product image display
- `mainAxisSpacing: 16`: Vertical gap between rows
- `crossAxisSpacing: 16`: Horizontal gap between columns
- **Consistency**: Same layout in shop, wishlist, category pages

---

## Summary

This documentation covers Member 2's UX enhancement contributions including:

### Search Functionality
- Real-time search with debouncing
- Case-insensitive filtering
- Performance optimization

### Sorting System
- Popup menu for sort options
- Price ascending/descending
- Default (no sort) option

### Dark Mode
- ThemeProvider with ChangeNotifier
- SharedPreferences persistence
- Light/Dark/System modes
- Toggle switch in profile

### Wishlist System
- Firestore cloud sync
- Optimistic UI updates
- Heart icon on product cards
- Dedicated wishlist page
- Add/remove functionality

### Enhanced Filtering
- Category dropdown
- Combined filters (category + search + sort)
- Dynamic category list generation

All features focus on improving user experience with smooth interactions, instant feedback, and persistent preferences. The implementations follow Flutter best practices for state management, data persistence, and performance optimization.
