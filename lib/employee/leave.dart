import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class LeaveFormScreen extends StatefulWidget {
  @override
  _LeaveFormScreenState createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController reasonController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String leaveType = 'Sick Leave';
  String teamLeader = 'Select Team Leader';
  String role = 'Select Role';
  bool isFullDay = true;
  bool isSubmitted = false;
  String leaveStatus = "";
  String approvalStatus = "";

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          if (endDate != null && startDate!.isAfter(endDate!)) {
            endDate = null;
          }
        } else {
          if (startDate != null && picked.isBefore(startDate!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("End date cannot be before start date")),
            );
          } else {
            endDate = picked;
          }
        }
      });
    }
  }

  Widget _buildDateContainer(String label, DateTime? date) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date == null ? label : "${date.toLocal()}".split(' ')[0],
              style: TextStyle(fontSize: 16)),
          Icon(Icons.calendar_today),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        startDate != null &&
        endDate != null) {
      setState(() {
        isSubmitted = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
    }
  }

  Widget _infoRow(String label, String value, [Color color = Colors.black]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Leave")),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: isSubmitted
            ? Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: 350,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long,
                                  size: 40, color: Color(0xFF777DF1)),
                              SizedBox(height: 10),
                              Text(
                                "LEAVE REQUEST RECEIPT",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.black45),
                        _infoRow("Type of Leave", leaveType, Colors.black87),
                        _infoRow(
                            "Start Date",
                            "${startDate!.toLocal()}".split(' ')[0],
                            Colors.black87),
                        _infoRow(
                            "End Date",
                            "${endDate!.toLocal()}".split(' ')[0],
                            Colors.black87),
                        _infoRow(
                            "Duration",
                            isFullDay ? "Full-Day" : "Half-Day",
                            Colors.black87),
                        _infoRow("Team Leader", teamLeader, Colors.black87),
                        _infoRow("Role", role, Colors.black87),
                        _infoRow(
                            "Reason", reasonController.text, Colors.black87),
                        _infoRow("Status", "Pending", Colors.orange),
                        Divider(color: Colors.black45),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF777DF1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isSubmitted = false;
                                reasonController.clear();
                                startDate = null;
                                endDate = null;
                                leaveType = 'Sick Leave';
                                teamLeader = 'Select Team Leader';
                                role = 'Select Role';
                                isFullDay = true;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text("Request Another Leave",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: leaveType,
                      decoration: InputDecoration(labelText: "Leave Type"),
                      items: ["Sick Leave", "Casual Leave", "Annual Leave"]
                          .map((String type) => DropdownMenuItem<String>(
                              value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(() => leaveType = value!),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: _buildDateContainer("Start Date", startDate),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: _buildDateContainer("End Date", endDate),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: Color(0xFF777DF1),
                      color: Colors.black,
                      textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold), // Increased text size
                      constraints: BoxConstraints(
                          minHeight: 50,
                          minWidth: 100), // Increased button size
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child:
                              Text("Full-Day", style: TextStyle(fontSize: 15)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child:
                              Text("Half-Day", style: TextStyle(fontSize: 15)),
                        ),
                      ],
                      isSelected: [isFullDay, !isFullDay],
                      onPressed: (index) =>
                          setState(() => isFullDay = index == 0),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: teamLeader,
                      decoration: InputDecoration(labelText: "Team Leader"),
                      items: ["Select Team Leader", "Arjun", "Sarathy"]
                          .map((String sup) => DropdownMenuItem<String>(
                              value: sup, child: Text(sup)))
                          .toList(),
                      onChanged: (value) => setState(() => teamLeader = value!),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: InputDecoration(labelText: "Role"),
                      items: [
                        "Select Role",
                        "Flutter Developer",
                        "Tester",
                        "Software Developer"
                      ]
                          .map((String sup) => DropdownMenuItem<String>(
                              value: sup, child: Text(sup)))
                          .toList(),
                      onChanged: (value) => setState(() => role = value!),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: reasonController,
                      decoration: InputDecoration(labelText: "Reason"),
                      validator: (value) =>
                          value!.isEmpty ? "Enter reason" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text("Submit Request"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
