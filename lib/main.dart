import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Options
import 'core/config/firebase_options.dart';

// Authentication Pages
import 'features/auth/presentation/pages/auth_page.dart';

// Dashboard Pages
import 'features/dashboard/presentation/pages/admin_dashboard_page.dart';
import 'features/dashboard/presentation/pages/user_dashboard_page.dart';

// Order Pages
import 'features/orders/presentation/pages/create_order_page.dart';
import 'features/orders/presentation/pages/modify_orders_page.dart';
import 'features/orders/presentation/pages/pending_orders_page.dart';
import 'features/orders/presentation/pages/completed_orders_page.dart';

// Services
import 'features/orders/data/services/user_role_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Configure Firestore to use persistent cache and network
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    runApp(ErrorApp(error: e));
    return;
  }
  
  runApp(const MyApp());
}

class ErrorApp extends StatelessWidget {
  final dynamic error;
  
  const ErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Initialization Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to initialize Firebase: $error\n\n'
              'Please check your internet connection and Firebase configuration.',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bohurupi Order CMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
        '/user-dashboard': (context) => const UserDashboardPage(),
        '/create-order': (context) => const CreateOrderPage(),
        '/modify-orders': (context) => const ModifyOrdersPage(),
        '/pending-orders': (context) => const PendingOrdersPage(),
        '/completed-orders': (context) => const CompletedOrdersPage(),
      },
      home: FirestoreConnectionChecker(),
    );
  }
}

class FirestoreConnectionChecker extends StatefulWidget {
  const FirestoreConnectionChecker({super.key});

  @override
  _FirestoreConnectionCheckerState createState() => _FirestoreConnectionCheckerState();
}

class _FirestoreConnectionCheckerState extends State<FirestoreConnectionChecker> {
  bool _isConnected = false;
  String _connectionStatus = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkFirestoreConnection();
  }

  Future<void> _checkFirestoreConnection() async {
    try {
      // Try to fetch a document from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get(const GetOptions(source: Source.server));
      
      setState(() {
        _isConnected = true;
        _connectionStatus = 'Firestore connection successful';
      });
    } catch (e) {
      try {
        // Fallback to cache if server connection fails
        await FirebaseFirestore.instance
            .collection('users')
            .limit(1)
            .get(const GetOptions(source: Source.cache));
        
        setState(() {
          _isConnected = true;
          _connectionStatus = 'Firestore connection successful (using cache)';
        });
      } catch (cacheError) {
        setState(() {
          _isConnected = false;
          _connectionStatus = 'Firestore connection failed: $cacheError';
        });
      }
    }

    // Proceed to authentication state
    if (_isConnected) {
      _proceedToAuthState();
    }
  }

  void _proceedToAuthState() {
    StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AuthPage()),
            );
          } else {
            // Determine dashboard based on user role
            _checkUserRole(user);
          }
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<void> _checkUserRole(User user) async {
    try {
      String userRole = await UserRoleService().getUserRole();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => userRole == 'admin'
              ? const AdminDashboardPage()
              : const UserDashboardPage(),
        ),
      );
    } catch (e) {
      // Handle role checking error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking user role: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _connectionStatus,
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            if (!_isConnected)
              ElevatedButton(
                onPressed: _checkFirestoreConnection,
                child: const Text('Retry Connection'),
              ),
          ],
        ),
      ),
    );
  }
}
