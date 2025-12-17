import 'package:flutter/material.dart';
import 'package:minimart/providers/auth_provider.dart';
import 'package:minimart/providers/cart_provider.dart';
import 'package:minimart/providers/orders_provider.dart';
import 'package:minimart/screens/order_confirmation_page.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _couponController = TextEditingController();
  String _selectedPaymentMethod = 'cod';
  bool _isLoading = false;
  bool _isCheckingCoupon = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate user data from AuthManager
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authManager = Provider.of<AuthManager>(context, listen: false);
      final userData = authManager.userData;
      final user = authManager.user;

      if (userData != null && user != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          // Optionally pre-populate address if available
          _addressController.text = userData['location'] ?? '';
        });
        debugPrint('[CheckoutPage] User data loaded: Name=${_nameController.text}, Phone=${_phoneController.text}');
      }
    } catch (e) {
      debugPrint('[CheckoutPage] Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          "Checkout",
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shipping Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your full name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "Enter your phone number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: "Delivery Address",
                hint: "Enter your full address",
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
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
                    ),
                    RadioListTile(
                      value: 'card',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value.toString();
                        });
                      },
                      title: const Text("Credit/Debit Card"),
                      secondary: const Icon(Icons.credit_card, color: Colors.blue),
                      activeColor: AppColors.primary,
                    ),
                    RadioListTile(
                      value: 'mobile_money',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value.toString();
                        });
                      },
                      title: const Text("Mobile Money (Bkash/Nagad)"),
                      secondary: const Icon(Icons.phone_android, color: Colors.pink),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Coupon Code",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.coupon != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Coupon Applied: ${cart.coupon!.code}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                                Text(
                                  cart.coupon!.discountType == 'percentage'
                                      ? "${cart.coupon!.discountValue}% OFF"
                                      : "৳${cart.coupon!.discountValue} OFF",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              cart.removeCoupon();
                              _couponController.clear();
                              CustomSnackBar.show(context, "Coupon removed");
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _couponController,
                          decoration: InputDecoration(
                            hintText: "Enter coupon code",
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
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isCheckingCoupon
                            ? null
                            : () async {
                                final code = _couponController.text.trim();
                                if (code.isEmpty) return;

                                setState(() {
                                  _isCheckingCoupon = true;
                                });

                                try {
                                  await cart.applyCoupon(code);
                                  if (context.mounted) {
                                    CustomSnackBar.show(
                                        context, "Coupon applied successfully!");
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    CustomSnackBar.show(context, e.toString(),
                                        isError: true);
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isCheckingCoupon = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: _isCheckingCoupon
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Apply",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Subtotal",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              "৳${cart.subtotal.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (cart.discountAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Discount",
                                  style: TextStyle(color: Colors.green),
                                ),
                                Text(
                                  "-৳${cart.discountAmount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Fee",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              "Free",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "৳${cart.totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer2<CartProvider, OrdersProvider>(
              builder: (context, cart, orders, child) {
                return ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              // Added delay for order processing simulation
                              await Future.delayed(const Duration(seconds: 2));

                              await orders.addOrder(
                                cart.items.values.toList(),
                                cart.totalAmount,
                                _nameController.text,
                                _phoneController.text,
                                _addressController.text,
                                _selectedPaymentMethod,
                                cart.coupon?.code,
                                cart.coupon?.discountType,
                                cart.coupon?.discountValue,
                              );
                              cart.clear();
                              if (context.mounted) {
                                CustomSnackBar.show(
                                  context,
                                  "Order placed successfully!",
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        const OrderConfirmationPage(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomSnackBar.show(
                                  context,
                                  "Failed to place order: $e",
                                  isError: true,
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Place Order",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            // Phone number validation
            if (label == 'Phone Number') {
              // Remove spaces, dashes, and leading + for validation
              String cleanPhone = value.replaceAll(RegExp(r'[\s\-+]'), '');
              // Accept if it's 10-15 digits, or has country code (88) followed by 11 digits
              if (!RegExp(r'^([0-9]{10,15}|88[0-9]{11})$').hasMatch(cleanPhone)) {
                return 'Please enter a valid phone number (10-15 digits or +8801XXXXXXXXX)';
              }
            }
            // Address validation
            if (label == 'Delivery Address') {
              if (value.length < 10) {
                return 'Please enter a complete address (at least 10 characters)';
              }
            }
            // Name validation
            if (label == 'Full Name') {
              if (value.length < 2) {
                return 'Please enter a valid name';
              }
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
