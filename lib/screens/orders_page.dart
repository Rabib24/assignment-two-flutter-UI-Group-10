import 'package:flutter/material.dart';
import 'package:minimart/theme/app_colors.dart';
import 'package:minimart/widgets/order_item_widget.dart';
import 'package:provider/provider.dart';
import 'package:minimart/providers/orders_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<OrdersProvider>(context, listen: false).fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Consumer<OrdersProvider>(
        builder: (context, orderData, child) {
          if (orderData.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No orders yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orderData.orders.length,
            itemBuilder: (context, index) {
              final order = orderData.orders[index];
              return OrderItemWidget(order: order);
            },
          );
        },
      ),
    );
  }
}
