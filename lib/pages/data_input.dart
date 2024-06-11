import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:trictux_chatroom/modules/sale_class.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addSale(BuildContext context) async {
    final TextEditingController totalItemsController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController totalSaleController = TextEditingController();
    final TextEditingController originalPriceController = TextEditingController();

    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Sale Data'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: totalItemsController,
                decoration: const InputDecoration(labelText: 'Total Items Sold'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    dateController.text = selectedDate!.toLocal().toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: totalSaleController,
                decoration: const InputDecoration(labelText: 'Total Sale'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: originalPriceController,
                decoration: const InputDecoration(labelText: 'Original Price of Item'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a date.')),
                );
                return;
              }

              final int totalItems = int.parse(totalItemsController.text);
              final DateTime date = selectedDate!;
              final double totalSale = double.parse(totalSaleController.text);
              final double originalPrice = double.parse(originalPriceController.text);

              // Check for duplicate date
              final existingSales = await _firestore
                  .collection('sales')
                  .where('date', isEqualTo: date.toIso8601String())
                  .get();
              if (existingSales.docs.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('A sale for this date already exists.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  )),
                );
                return;
              }

              final double tax = totalSale * 0.16;
              final double remaining = totalSale - tax;
              final double sellingPrice = remaining / totalItems;
              final double profit = sellingPrice - originalPrice;

              final Sale sale = Sale(
                id: '',
                date: date,
                totalItemsSold: totalItems,
                totalSale: totalSale,
                originalPrice: originalPrice,
                sellingPrice: sellingPrice,
                profit: profit,
              );

              await _firestore.collection('sales').add(sale.toMap());

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Sales',
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,

      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('sales').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final sales = snapshot.data!.docs.map((doc) => Sale.fromFirestore(doc)).toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.custom(
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: [
                  QuiltedGridTile(2, 2),
                  QuiltedGridTile(1, 1),
                  QuiltedGridTile(1, 1),
                ],
              ),
              childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final sale = sales[index];
                  final color = Colors.primaries[index % Colors.primaries.length];

                  return Card(
                    color: color,
                    child: Center(
                      child: ListTile(
                        title: Text('Date: ${sale.date.toLocal().toString().split(' ')[0]}'),
                        subtitle: Text('Total Sale: ${sale.totalSale.toStringAsFixed(2)}'),
                        onTap: () => _editSale(context, sale),
                      ),
                    ),
                  );
                },
                childCount: sales.length,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSale(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _editSale(BuildContext context, Sale sale) async {
    final TextEditingController totalItemsController = TextEditingController(text: sale.totalItemsSold.toString());
    final TextEditingController dateController = TextEditingController(text: sale.date.toIso8601String().split('T')[0]);
    final TextEditingController totalSaleController = TextEditingController(text: sale.totalSale.toString());
    final TextEditingController originalPriceController = TextEditingController(text: sale.originalPrice.toString());

    DateTime? selectedDate = sale.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Sale Data'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: totalItemsController,
                decoration: const InputDecoration(labelText: 'Total Items Sold'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                readOnly: true,
                onTap: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    dateController.text = selectedDate!.toLocal().toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: totalSaleController,
                decoration: const InputDecoration(labelText: 'Total Sale'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: originalPriceController,
                decoration: const InputDecoration(labelText: 'Original Price of Item'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a date.')),
                );
                return;
              }

              final int totalItems = int.parse(totalItemsController.text);
              final DateTime date = selectedDate!;
              final double totalSale = double.parse(totalSaleController.text);
              final double originalPrice = double.parse(originalPriceController.text);

              // Check for duplicate date
              final existingSales = await _firestore
                  .collection('sales')
                  .where('date', isEqualTo: date.toIso8601String())
                  .get();
              if (existingSales.docs.isNotEmpty && existingSales.docs.first.id != sale.id) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('A sale for this date already exists.')),
                );
                return;
              }

              final double tax = totalSale * 0.16;
              final double remaining = totalSale - tax;
              final double sellingPrice = remaining / totalItems;
              final double profit = sellingPrice - originalPrice;

              final updatedSale = Sale(
                id: sale.id,
                date: date,
                totalItemsSold: totalItems,
                totalSale: totalSale,
                originalPrice: originalPrice,
                sellingPrice: sellingPrice,
                profit: profit,
              );

              await _firestore.collection('sales').doc(sale.id).update(updatedSale.toMap());

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
