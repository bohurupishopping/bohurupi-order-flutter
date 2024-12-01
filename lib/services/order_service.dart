import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CustomOrder>> getAllOrders() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('orders').get();
    return snapshot.docs.map((doc) => CustomOrder.fromMap(doc.data())).toList();
  }

  Future<void> updateOrder(CustomOrder order) async {
    await _firestore.collection('orders').doc(order.orderId).update(order.toMap());
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }
}
