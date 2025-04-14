import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'face_verfication.dart';

class VerificationScreen extends StatefulWidget {
  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isFaceVerified = false;
  bool _isLocationVerified = false;
  bool _isLoading = false;
  String _location = "";

  Future<void> _verifyLocation() async {
    setState(() {
      _isLoading = true;
      _isLocationVerified = false;
      _location = "";
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _location =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
          _isLocationVerified = true;
        });
      }
    } catch (e) {
      setState(() {
        _location = "Failed to get location.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyFace() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FaceVerificationScreen()),
    );

    if (result == true) {
      setState(() {
        _isFaceVerified = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Employee Verification")),
        drawer: AppDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NameEntryCard(nameController: _nameController),
                SizedBox(height: 15),

                // Face Verification
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.face, size: 40, color: Colors.blueAccent),
                        SizedBox(height: 8),
                        Text("Verify Employee Face",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text(
                            "Ensure the employee's identity by scanning their face.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                        SizedBox(height: 10),
                        _isFaceVerified
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 24),
                                  SizedBox(width: 5),
                                  Text("Verified",
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold)),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: _verifyFace,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Verify"),
                              ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // Location Verification
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            size: 40, color: Colors.blueAccent),
                        SizedBox(height: 8),
                        Text("Verify Employee Location",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text("Check the employee's current location.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                        SizedBox(height: 10),
                        _isLoading
                            ? CircularProgressIndicator()
                            : _isLocationVerified
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 24),
                                      SizedBox(width: 5),
                                      Text("Verified",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: _verifyLocation,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text("Verify"),
                                  ),
                        if (_location.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _location,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class NameEntryCard extends StatelessWidget {
  final TextEditingController nameController;

  NameEntryCard({required this.nameController});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("Enter Employee Name",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Employee Name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
