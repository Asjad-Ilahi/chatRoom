import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String id;
  DateTime date;
  int totalItemsSold;
  double totalSale;
  double originalPrice;
  double sellingPrice;
  double profit;

  Sale({
    required this.id,
    required this.date,
    required this.totalItemsSold,
    required this.totalSale,
    required this.originalPrice,
    required this.sellingPrice,
    required this.profit,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Sale(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      totalItemsSold: data['totalItemsSold'],
      totalSale: data['totalSale'],
      originalPrice: data['originalPrice'],
      sellingPrice: data['sellingPrice'],
      profit: data['profit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'totalItemsSold': totalItemsSold,
      'totalSale': totalSale,
      'originalPrice': originalPrice,
      'sellingPrice': sellingPrice,
      'profit': profit,
    };
  }
}
