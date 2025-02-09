import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DonationEligibilityForm extends StatefulWidget {
  final String name;
  final String email;
  final String imgUrl;
  final User? user;

  DonationEligibilityForm({
    required this.name,
    required this.email,
    required this.imgUrl,
    required this.user,
  });

  @override
  _DonationEligibilityFormState createState() =>
      _DonationEligibilityFormState();
}

class _DonationEligibilityFormState extends State<DonationEligibilityForm> {
  DateTime? selectedDate;
  String? bloodType;
  String area = '';
  String state = '';
  bool isLoading = false; // Initially false, location is not fetched yet
  bool isAgeVerified = false;
  bool locationFetched = false; // Track if location has been fetched

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true; // Show loading indicator while fetching
      area = 'Fetching location...'; // Optional: Display a message
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            area = 'Location permission denied';
            isLoading = false;
            locationFetched = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          area = place.locality ?? place.subLocality ?? '';
          state = place.administrativeArea ?? '';
          isLoading = false;
          locationFetched = true; // Set to true after successful fetch
        });
      }
    } catch (e) {
      setState(() {
        area = 'Error fetching location';
        isLoading = false;
        locationFetched = false;
      });
    }
  }

  Widget _buildLocationDisplay() {
    if (!locationFetched) {
      // Show the button if location hasn't been fetched
      return Center(
        child: ElevatedButton(
          onPressed: _getCurrentLocation,
          child: Text('Check Location'),
        ),
      );
    }

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            '$area, $state',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        TextButton.icon(
          icon: Icon(Icons.refresh, size: 20),
          label: Text('Refresh'),
          onPressed: _getCurrentLocation,
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        final age = DateTime.now().difference(picked).inDays / 365;
        isAgeVerified = age >= 18;
      });
    }
  }

  Future<void> _storeUserData() async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      final userData = {
        'uid': widget.user!.uid,
        'name': widget.name,
        'email': widget.email,
        'imgUrl': widget.imgUrl,
        'location': '$area, $state',
        'bloodGroup': bloodType,
        'dob': selectedDate != null ? selectedDate!.toIso8601String() : null,
      };

      await usersCollection.doc(widget.user!.uid).set(userData);

      Navigator.of(context).pushNamed('/home');
    } catch (e) {
      print('Error storing data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error storing data. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Eligibility'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date of Birth',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(selectedDate!)
                                  : 'Select Date',
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              isAgeVerified ? Icons.check_circle : Icons.error,
                              color: isAgeVerified ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isAgeVerified
                                  ? '18+ Verified'
                                  : 'Must be 18 or older',
                              style: TextStyle(
                                color:
                                    isAgeVerified ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blood Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: bloodType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      hint: Text('Select Blood Type'),
                      items: bloodTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          bloodType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildLocationDisplay(), // The updated location display
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    (isAgeVerified && bloodType != null && locationFetched)
                        ? _storeUserData
                        : null,
                child: Text(
                  'Continue',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
