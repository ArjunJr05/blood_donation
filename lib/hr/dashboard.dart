import 'package:animations/animations.dart';
import 'package:blood/home/drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HRDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR Dashboard'),
        backgroundColor: Color(0xFF777DF1),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnimatedStatCard("Attendance", "85%", Colors.green),
                _buildAnimatedStatCard("Leaves", "12%", Colors.orange),
                _buildAnimatedStatCard("Pending", "5", Colors.red),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildChartCard("Attendance Overview", _buildPieChart()),
                  _buildChartCard("Leave Trends", _buildBarChart()),
                  _buildChartCard("Pending Applications", _buildLineChart()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatCard(String title, String value, Color color) {
    return OpenContainer(
      closedElevation: 4,
      closedShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      closedColor: Colors.grey.shade200,
      openColor: Colors.white,
      closedBuilder: (context, action) => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
      openBuilder: (context, action) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text("Detailed View of $title")),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.grey.shade100,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 85,
            color: Colors.green.shade600,
            title: '85%',
            radius: 50,
            titleStyle: TextStyle(color: Colors.white, fontSize: 16),
          ),
          PieChartSectionData(
            value: 15,
            color: Colors.red.shade600,
            title: '15%',
            radius: 50,
            titleStyle: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
        sectionsSpace: 0,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt() == 1 ? 'Jan' : 'Feb',
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        barGroups: [
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 12,
                color: Colors.orange.shade600,
                width: 25,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 8,
                color: Colors.orange.shade400,
                width: 25,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 4,
        minY: 0,
        maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 3),
              FlSpot(2, 5),
              FlSpot(3, 2),
            ],
            isCurved: true,
            color: Colors.red.shade700,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
