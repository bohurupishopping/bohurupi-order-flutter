import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _currentUserName = 'Admin';
  
  int _pendingOrdersCount = 0;
  int _completedOrdersCount = 0;
  int _totalOrdersCount = 0;

  @override
  void initState() {
    super.initState();
    _checkUserDetails();
    _fetchOrderStats();
  }

  Future<void> _checkUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserName = currentUser.displayName ?? 'Admin';
      });
    }
  }

  Future<void> _fetchOrderStats() async {
    try {
      final pendingQuery = await _firestore.collection('orders')
        .where('status', isEqualTo: 'Pending')
        .get();
      
      final completedQuery = await _firestore.collection('orders')
        .where('status', isEqualTo: 'Delivered')
        .get();
      
      final totalQuery = await _firestore.collection('orders').get();

      setState(() {
        _pendingOrdersCount = pendingQuery.docs.length;
        _completedOrdersCount = completedQuery.docs.length;
        _totalOrdersCount = totalQuery.docs.length;
      });
    } catch (e) {
      print('Error fetching order stats: $e');
    }
  }

  Widget _buildStatCard({
    required String title, 
    required int value, 
    required Color color, 
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple[700],
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple[400]!,
              Colors.purple[700]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $_currentUserName',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Admin Dashboard',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed('/auth');
                      },
                    ),
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildStatCard(
                      title: 'Total Orders',
                      value: _totalOrdersCount,
                      color: Colors.blue,
                      icon: Icons.shopping_cart,
                    ),
                    _buildStatCard(
                      title: 'Pending',
                      value: _pendingOrdersCount,
                      color: Colors.orange,
                      icon: Icons.pending_actions,
                    ),
                    _buildStatCard(
                      title: 'Completed',
                      value: _completedOrdersCount,
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              ),

              // Actions
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildActionButton(
                        title: 'Create Order',
                        icon: Icons.add_circle,
                        onPressed: () => Navigator.of(context).pushNamed('/create-order'),
                      ),
                      _buildActionButton(
                        title: 'Modify Orders',
                        icon: Icons.edit,
                        onPressed: () => Navigator.of(context).pushNamed('/modify-orders'),
                      ),
                      _buildActionButton(
                        title: 'Pending Orders',
                        icon: Icons.pending_actions,
                        onPressed: () => Navigator.of(context).pushNamed('/pending-orders'),
                      ),
                      _buildActionButton(
                        title: 'Completed Orders',
                        icon: Icons.check_circle,
                        onPressed: () => Navigator.of(context).pushNamed('/completed-orders'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
