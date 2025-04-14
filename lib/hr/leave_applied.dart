import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';

class HRLeaveRequestsScreen extends StatefulWidget {
  @override
  _HRLeaveRequestsScreenState createState() => _HRLeaveRequestsScreenState();
}

class _HRLeaveRequestsScreenState extends State<HRLeaveRequestsScreen> {
  // Dummy list of leave requests (replace with data from your backend)
  final List<Map<String, dynamic>> leaveRequests = [
    {
      "id": "1",
      "employeeName": "John Doe",
      "leaveType": "Sick Leave",
      "startDate": "2023-10-15",
      "endDate": "2023-10-17",
      "reason": "Fever and cold",
      "status": "Pending",
    },
    {
      "id": "2",
      "employeeName": "Jane Smith",
      "leaveType": "Casual Leave",
      "startDate": "2023-10-20",
      "endDate": "2023-10-21",
      "reason": "Family function",
      "status": "Pending",
    },
  ];

  void _updateLeaveStatus(String id, String status) {
    setState(() {
      leaveRequests.firstWhere((request) => request["id"] == id)["status"] =
          status;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Leave request $status")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Requests"),
        backgroundColor: Color(0xFF777DF1),
      ),
      drawer: AppDrawer(),
      body: Container(
        color: const Color.fromARGB(
            255, 230, 228, 228), // Default background color
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: leaveRequests.length,
          itemBuilder: (context, index) {
            final request = leaveRequests[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Increased opacity
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Employee: ${request["employeeName"]}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Dark text for contrast
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow("Leave Type", request["leaveType"]),
                    _buildInfoRow("Start Date", request["startDate"]),
                    _buildInfoRow("End Date", request["endDate"]),
                    _buildInfoRow("Reason", request["reason"]),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status: ${request["status"]}",
                          style: TextStyle(
                            fontSize: 16,
                            color: request["status"] == "Approved"
                                ? Colors.green
                                : request["status"] == "Rejected"
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (request["status"] == "Pending")
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                SizedBox(width: 60),
                                ElevatedButton(
                                  onPressed: () => _updateLeaveStatus(
                                      request["id"], "Approved"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF777DF1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text("Accept"),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _updateLeaveStatus(
                                      request["id"], "Rejected"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF777DF1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text("Reject"),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Dark text for contrast
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.black87), // Dark text for contrast
          ),
        ],
      ),
    );
  }
}
