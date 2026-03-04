import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch call to $phoneNumber')),
        );
      }
    }
  }

  Future<void> _adjustStock(String sizeKey, int amount) async {
    try {
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc('sneakers')
          .set({
            sizeKey: FieldValue.increment(amount),
          }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to adjust stock: $e')));
      }
    }
  }

  void _showStockAdjustmentDialog(
    Map<String, dynamic> stockData, {
    String? initialSize,
    String? initialColor,
  }) {
    final controller = TextEditingController();
    String selectedSize = initialSize ?? 'S';
    String selectedColor = initialColor ?? 'Black';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Adjust Stock: $selectedSize-$selectedColor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Current Stock:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'S-Black: ${stockData['S_Black'] ?? 0} | S-White: ${stockData['S_White'] ?? 0}',
              ),
              Text(
                'L-Black: ${stockData['L_Black'] ?? 0} | L-White: ${stockData['L_White'] ?? 0}',
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: selectedSize,
                decoration: const InputDecoration(
                  labelText: 'Select Size',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'S', child: Text('S (36-39)')),
                  DropdownMenuItem(value: 'L', child: Text('L (40-45)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedSize = val);
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedColor,
                decoration: const InputDecoration(
                  labelText: 'Select Color',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Black', child: Text('Black')),
                  DropdownMenuItem(value: 'White', child: Text('White')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedColor = val);
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  final val = int.tryParse(value);
                  if (val != null && val != 0) {
                    _adjustStock('${selectedSize}_$selectedColor', val);
                    Navigator.pop(context);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Amount to add/remove',
                  hintText: 'e.g., 50 or -20',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val != 0) {
                  _adjustStock('${selectedSize}_$selectedColor', val);
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(OrderModel order, OrderStatus newStatus) async {
    try {
      // 1. Determine stock changes if any
      bool shouldDeduct = false;
      bool shouldRestore = false;

      // Status logic:
      // Orders start at 'pending' (stock not deducted yet)
      // Moving TO 'ongoing' or 'complete' from 'pending' -> Deduct
      if (order.status == OrderStatus.pending &&
          (newStatus == OrderStatus.ongoing ||
              newStatus == OrderStatus.complete)) {
        shouldDeduct = true;
      }

      // Moving TO 'pending' or 'canceled' from ('ongoing' or 'complete') -> Restore
      if ((order.status == OrderStatus.ongoing ||
              order.status == OrderStatus.complete) &&
          (newStatus == OrderStatus.pending ||
              newStatus == OrderStatus.canceled)) {
        shouldRestore = true;
      }

      // 2. Perform stock adjustment if needed
      final sizeKey = order.size.contains('S') ? 'S' : 'L';
      final storageKey = "${sizeKey}_${order.color}";

      if (shouldDeduct) {
        await _adjustStock(storageKey, -order.quantity);
      } else if (shouldRestore) {
        await _adjustStock(storageKey, order.quantity);
      }

      // 3. Update the order status in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update({'status': newStatus.name});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
      }
    }
  }

  Future<void> _updateOrderDetails(
    OrderModel order,
    String location,
    String note,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.id)
          .update({'location': location, 'note': note});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update details: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, orderSnapshot) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('inventory')
              .doc('sneakers')
              .snapshots(),
          builder: (context, inventorySnapshot) {
            if (orderSnapshot.hasError || inventorySnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Error: ${orderSnapshot.error ?? inventorySnapshot.error}',
                  ),
                ),
              );
            }
            if (orderSnapshot.connectionState == ConnectionState.waiting ||
                inventorySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final allOrders = orderSnapshot.data!.docs.map((doc) {
              return OrderModel.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              );
            }).toList();

            final stockData =
                (inventorySnapshot.data?.data() as Map<String, dynamic>?) ?? {};

            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                title: const Text(
                  'Admin Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboard(allOrders, stockData),
                  _buildOrderList(allOrders, OrderStatus.pending),
                  _buildOrderList(allOrders, OrderStatus.ongoing),
                  _buildOrderList(allOrders, OrderStatus.complete),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blueGrey,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Stats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.pending_actions),
                    label: 'Pending',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.delivery_dining),
                    label: 'Ongoing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: 'Done',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboard(
    List<OrderModel> orders,
    Map<String, dynamic> stockData,
  ) {
    final pendingCount = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final ongoingCount = orders
        .where((o) => o.status == OrderStatus.ongoing)
        .length;
    final completeOrders = orders
        .where((o) => o.status == OrderStatus.complete)
        .toList();
    final totalSales = completeOrders.length;
    final totalEarnings = completeOrders.fold(
      0.0,
      (total, o) => total + o.totalPrice,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatCard('Total Sales (Complete)', '$totalSales', Colors.green),
          _buildStatCard(
            'Total Earnings',
            '${totalEarnings.toStringAsFixed(2)} LYD',
            Colors.blue,
          ),
          _buildStatCard('Pending Orders', '$pendingCount', Colors.orange),
          _buildStatCard('Ongoing Orders', '$ongoingCount', Colors.indigo),
          _buildStatCard(
            'Stock: S-Black',
            '${stockData['S_Black'] ?? 0}',
            Colors.blueGrey,
            onTap: () => _showStockAdjustmentDialog(
              stockData,
              initialSize: 'S',
              initialColor: 'Black',
            ),
          ),
          _buildStatCard(
            'Stock: S-White',
            '${stockData['S_White'] ?? 0}',
            Colors.blueGrey,
            onTap: () => _showStockAdjustmentDialog(
              stockData,
              initialSize: 'S',
              initialColor: 'White',
            ),
          ),
          _buildStatCard(
            'Stock: L-Black',
            '${stockData['L_Black'] ?? 0}',
            Colors.blueGrey,
            onTap: () => _showStockAdjustmentDialog(
              stockData,
              initialSize: 'L',
              initialColor: 'Black',
            ),
          ),
          _buildStatCard(
            'Stock: L-White',
            '${stockData['L_White'] ?? 0}',
            Colors.blueGrey,
            onTap: () => _showStockAdjustmentDialog(
              stockData,
              initialSize: 'L',
              initialColor: 'White',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border(left: BorderSide(color: color, width: 5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (onTap != null) const Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, OrderStatus status) {
    final filtered = orders.where((o) => o.status == status).toList();

    if (filtered.isEmpty) {
      return Center(child: Text('No ${status.name} orders'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(filtered[index]);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 5)}...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${order.totalPrice} LYD',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Name: ${order.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _makeCall(order.phone),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      'Phone: ${order.phone}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text('City: ${order.city}'),
            Text('Details: ${order.quantity}x ${order.color} (${order.size})'),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Exact Location',
                hintText: 'Enter specific street or landmark',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) => _updateOrderDetails(order, val, order.note),
              controller: TextEditingController(text: order.location),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Additional delivery instructions',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (val) =>
                  _updateOrderDetails(order, order.location, val),
              controller: TextEditingController(text: order.note),
            ),
            const SizedBox(height: 15),
            _buildActionButtons(order),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateStatus(order, OrderStatus.ongoing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Move to Ongoing'),
              ),
            ),
          ],
        );
      case OrderStatus.ongoing:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateStatus(order, OrderStatus.pending),
                child: const Text('Back to Pending'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateStatus(order, OrderStatus.complete),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete'),
              ),
            ),
          ],
        );
      case OrderStatus.complete:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'pending') {
                  _updateStatus(order, OrderStatus.pending);
                } else if (val == 'cancel') {
                  _updateStatus(order, OrderStatus.canceled);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pending',
                  child: Text('Back to Pending'),
                ),
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text(
                    'Cancel Order',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        );
      case OrderStatus.canceled:
        return const Center(
          child: Text('Order Canceled', style: TextStyle(color: Colors.red)),
        );
    }
  }
}
