import 'package:cloud_firestore/cloud_firestore.dart';

class CustomOrder {
  String orderId;
  String customerName;
  String productName;
  int quantity;
  double price;
  String status;
  Timestamp orderDate;
  String? orderStatus;
  String? color;
  String? size;
  String? imageUrl;
  String? downloadDesign;
  String? courier;

  CustomOrder({
    required this.orderId,
    required this.customerName,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.status,
    required this.orderDate,
    this.orderStatus,
    this.color,
    this.size,
    this.imageUrl,
    this.downloadDesign,
    this.courier,
  });

  factory CustomOrder.fromMap(Map<String, dynamic> map) {
    return CustomOrder(
      orderId: map['orderId'] ?? '',
      customerName: map['customerName'] ?? map['name'] ?? '',
      productName: map['productName'] ?? map['details'] ?? '',
      quantity: map['quantity'] ?? map['qty'] ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      orderDate: map['orderDate'] ?? Timestamp.now(),
      orderStatus: map['orderStatus'] ?? map['orderstatus'],
      color: map['color'] ?? map['colour'],
      size: map['size'],
      imageUrl: map['imageUrl'] ?? map['image'],
      downloadDesign: map['downloadDesign'] ?? map['downloaddesign'],
      courier: map['courier'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'status': status,
      'orderDate': orderDate,
      'orderStatus': orderStatus,
      'color': color,
      'size': size,
      'imageUrl': imageUrl,
      'downloadDesign': downloadDesign,
      'courier': courier,
    };
  }
}
