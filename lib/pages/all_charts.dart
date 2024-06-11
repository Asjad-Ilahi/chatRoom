import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trictux_chatroom/modules/sale_class.dart';

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Sale>> _fetchSales() async {
    final snapshot = await _firestore.collection('sales').get();
    return snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
  }

  List<LineChartBarData> _generateLineChartData(List<Sale> sales) {
    final salesLast7Days = sales
        .where((sale) => sale.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    final salesPerDay = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final salesForDate = salesLast7Days.where((sale) => sale.date.day == date.day).toList();
      return FlSpot(index.toDouble(), salesForDate.fold(0, (sum, sale) => sum + sale.totalItemsSold).toDouble());
    });

    return [
      LineChartBarData(
        spots: salesPerDay,
        isCurved: true,
        color: Colors.orange, // Changed to white
        barWidth: 2,
        belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.2)), // Changed to white with opacity
      ),
    ];
  }

  List<PieChartSectionData> _generatePieChartData(List<Sale> sales) {
    final totalSales = sales.fold(0, (sum, sale) => sum + sale.totalSale.toInt());
    final totalProfits = sales.fold(0, (sum, sale) => sum + sale.profit.toInt());

    return [
      PieChartSectionData(
        value: totalSales.toDouble(),
        color: Colors.orange,
        title: 'Sales',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        value: totalProfits.toDouble(),
        color: Colors.green,
        title: 'Profits',
        radius: 100,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  List<BarChartGroupData> _generateBarChartData(List<Sale> sales) {
    final salesLast7Days = sales
        .where((sale) => sale.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final salesForDate = salesLast7Days.where((sale) => sale.date.day == date.day).toList();

      final totalSales = salesForDate.fold(0, (sum, sale) => sum + sale.totalSale.toInt());
      final totalProfits = salesForDate.fold(0, (sum, sale) => sum + sale.profit.toInt());

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: totalSales.toDouble(), color: Colors.orange),
          BarChartRodData(toY: totalProfits.toDouble(), color: Colors.green),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Sales Charts',
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<Sale>>(
        future: _fetchSales(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final sales = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10,),
                const Text(
                  'Sales Over Last 7 Days',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: _generateLineChartData(sales),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                              return Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              value.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            reservedSize: 40, // Added reserved size for the left titles
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 10,),// Added divider
                const Text(
                  'Sales and Profits Distribution',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _generatePieChartData(sales),
                      sectionsSpace: 2, // Space between sections
                      centerSpaceColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                const Divider(color: Colors.grey, thickness: 0.5),
                const SizedBox(height: 10,),// Added divider
                const Text(
                  'Sales and Profits Over Last 7 Days',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      barGroups: _generateBarChartData(sales),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                              return Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              value.toString(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            reservedSize: 40, // Added reserved size for the left titles
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
