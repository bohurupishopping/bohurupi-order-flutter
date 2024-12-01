import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/user_role_service.dart';
import '../widgets/order_form_widget.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final UserRoleService _userRoleService = UserRoleService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  bool _isAdmin = false;

  final Map<String, dynamic> _initialOrderDetails = {
    'status': 'Pending',
    'orderstatus': 'Prepaid',
    'courier': 'Delivery',
    'name': '',
    'details': 'Pure Cotton',
    'colour': 'Black',
    'size': '',
    'qty': 1,
    'image': '',
    'downloaddesign': '',
  };

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
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isAdmin = false;
      });
      Navigator.of(context).pushReplacementNamed('/user-dashboard');
    }
  }

  Future<void> _submitOrder(Map<String, dynamic> orderDetails) async {
    try {
      await _firestore.collection('orders').add(orderDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order created successfully!', 
            style: GoogleFonts.poppins(fontSize: 14)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating order: $e',
            style: GoogleFonts.poppins(fontSize: 14)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAdmin) {
      return const Scaffold(body: Center(child: Text('Access Denied')));
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Create New Order',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.purple[700],
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFf3e7e9),
              Color(0xFFe3eeff),
              Color(0xFFe3eeff),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: OrderFormWidget(
            initialOrderDetails: _initialOrderDetails,
            onSubmit: _submitOrder,
          ),
        ),
      ),
    );
  }
}
