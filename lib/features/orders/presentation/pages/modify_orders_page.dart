import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/services/user_role_service.dart';
import '../../../../models/order_model.dart';
import '../../../../services/order_service.dart';
import '../widgets/order_form_widget.dart';
import '../widgets/order_card_widget.dart';

class ModifyOrdersPage extends StatefulWidget {
  const ModifyOrdersPage({super.key});

  @override
  _ModifyOrdersPageState createState() => _ModifyOrdersPageState();
}

class _ModifyOrdersPageState extends State<ModifyOrdersPage> {
  final UserRoleService _userRoleService = UserRoleService();
  final OrderService _orderService = OrderService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CustomOrder? _selectedOrder;
  List<CustomOrder> _orders = [];
  bool _isLoading = true;
  bool _isAdmin = false;
  final TextEditingController _searchController = TextEditingController();
  List<CustomOrder> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      String userRole = await _userRoleService.getUserRole();
      setState(() {
        _isAdmin = userRole == 'admin';
        _isLoading = false;
      });
      if (!_isAdmin) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed('/user-dashboard');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access Denied: Admin only')),
          );
        });
      } else {
        _loadOrders();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isAdmin = false;
      });
      Navigator.of(context).pushReplacementNamed('/user-dashboard');
    }
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _orderService.getAllOrders();
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  void _filterOrders(String query) {
    setState(() {
      _filteredOrders = _orders.where((order) {
        return order.customerName.toLowerCase().contains(query.toLowerCase()) ||
               order.productName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showEditOrderDialog(CustomOrder order) {
    // Predefined lists for dropdowns
    final List<String> statusOptions = ['Pending', 'Delivered'];
    final List<String> orderStatusOptions = ['Prepaid', 'COD'];
    final List<String> productDetailsOptions = ['Pure Cotton', 'Full Sleeve', 'Poly Cotton', 'Polyester', 'Mobile Cover', 'Coffee Mug'];
    final List<String> colourOptions = ['Black', 'White', 'Blue', 'Green', 'Maroon', 'Yellow', 'None'];

    // Convert CustomOrder to the format expected by OrderFormWidget
    final Map<String, dynamic> initialOrderDetails = {
      'status': order.status,
      'orderstatus': order.orderStatus ?? orderStatusOptions.first,
      'name': order.customerName,
      'details': order.productName,
      'colour': order.color ?? colourOptions.first,
      'size': order.size ?? '',
      'qty': order.quantity,
      'image': order.imageUrl ?? '',
      'downloaddesign': order.downloadDesign ?? '',
      'courier': order.courier ?? '',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Order', style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.purple[700],
        )),
        content: SingleChildScrollView(
          child: OrderFormWidget(
            initialOrderDetails: initialOrderDetails,
            onSubmit: (updatedDetails) => _updateOrder(order, updatedDetails),
            isEditMode: true,
          ),
        ),
      ),
    );
  }

  void _updateOrder(CustomOrder originalOrder, Map<String, dynamic> updatedDetails) async {
    try {
      // Convert updated details back to CustomOrder
      final updatedOrder = CustomOrder(
        orderId: originalOrder.orderId,
        customerName: updatedDetails['name'],
        productName: updatedDetails['details'],
        quantity: updatedDetails['qty'],
        price: originalOrder.price,
        status: updatedDetails['status'],
        orderDate: originalOrder.orderDate,
        orderStatus: updatedDetails['orderstatus'],
        color: updatedDetails['colour'],
        size: updatedDetails['size'],
        imageUrl: updatedDetails['image'],
        downloadDesign: updatedDetails['downloaddesign'],
        courier: updatedDetails['courier'],
      );

      await _orderService.updateOrder(updatedOrder);
      
      // Reload orders after update
      await _loadOrders();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated successfully!', 
            style: GoogleFonts.poppins(fontSize: 14)),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e', 
            style: GoogleFonts.poppins(fontSize: 14)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteOrder(String orderId) async {
    // Show confirmation dialog before deleting
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this order?', 
          style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', 
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _orderService.deleteOrder(orderId);
        
        // Reload orders after deletion
        await _loadOrders();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order deleted successfully', 
              style: GoogleFonts.poppins(fontSize: 14)),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete order: $e', 
              style: GoogleFonts.poppins(fontSize: 14)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOrderCardWithActions(CustomOrder order) {
    // Convert CustomOrder to the format expected by OrderCardWidget
    final Map<String, dynamic> orderData = {
      'id': order.orderId,
      'customerName': order.customerName,
      'details': order.productName,
      'status': order.status,
      'quantity': order.quantity.toString(),
      'color': order.color ?? 'N/A',
      'size': order.size ?? 'N/A',
      'courier': order.courier ?? 'N/A',
      'orderStatus': order.orderStatus ?? 'N/A',
      'imageUrl': order.imageUrl ?? '',
      'downloadDesign': order.downloadDesign ?? 'N/A',
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          OrderCardWidget(order: orderData),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showEditOrderDialog(order),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: Text('Edit', style: GoogleFonts.poppins(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _deleteOrder(order.orderId),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
          ),
        ),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(body: Center(child: Text('Access Denied')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Orders', style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
        backgroundColor: Colors.purple[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: Icon(Icons.search, color: Colors.purple[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[700]!, width: 2),
                ),
              ),
              onChanged: _filterOrders,
            ),
          ),

          // Orders List
          Expanded(
            child: _filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      'No orders found', 
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      return _buildOrderCardWithActions(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
