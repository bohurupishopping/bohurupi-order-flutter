import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/order_card_widget.dart';
import '../../../../models/order_model.dart';

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  State<CompletedOrdersPage> createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);
    _fetchOrders();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'Delivered')
          .get();

      setState(() {
        _orders = querySnapshot.docs
            .map((doc) {
              // Convert Firestore document to a comprehensive map
              final data = doc.data();
              return {
                'id': doc.id,
                'customerName': data['customerName'] ?? data['name'] ?? 'N/A',
                'details': data['productName'] ?? data['details'] ?? 'N/A',
                'status': data['status'] ?? 'N/A',
                'quantity': data['quantity'] ?? data['qty'] ?? 0,
                'color': data['color'] ?? data['colour'] ?? 'N/A',
                'size': data['size'] ?? 'N/A',
                'courier': data['courier'] ?? 'N/A',
                'orderStatus': data['orderStatus'] ?? data['orderstatus'] ?? 'N/A',
                'imageUrl': data['imageUrl'] ?? data['image'] ?? '',
                'downloadDesign': data['downloadDesign'] ?? data['downloaddesign'] ?? 'N/A',
              };
            })
            .toList();
      });
    } catch (e) {
      _showErrorDialog('Error fetching orders: $e');
    } finally {
      _refreshController.refreshCompleted();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Delivered Orders',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDDB92), Color(0xFFD1FDFF)],
          ),
        ),
        child: SafeArea(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withOpacity(0.3),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _orders.isEmpty
                        ? Center(
                            child: Text(
                              'No Delivered Orders',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                          )
                        : SmartRefresher(
                            controller: _refreshController,
                            onRefresh: _fetchOrders,
                            child: ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return AnimatedBuilder(
                                  animation: _animation,
                                  builder: (context, child) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: OrderCardWidget(order: order),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchOrders,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.refresh),
      ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
    );
  }
}
