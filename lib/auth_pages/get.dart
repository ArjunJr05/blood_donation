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
    required String role,
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
  bool isLoading = false;
  bool isAgeVerified = false;
  bool locationFetched = false;
  bool isLocationButtonLoading = false;

  // Phone verification states
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  bool isPhoneVerified = false;
  bool isOtpSent = false;
  String? verificationId;
  bool isVerifyingPhone = false;

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

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLocationButtonLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            area = 'Location permission denied';
            isLocationButtonLoading = false;
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
          isLocationButtonLoading = false;
          locationFetched = true;
        });
      }
    } catch (e) {
      setState(() {
        area = 'Error fetching location';
        isLocationButtonLoading = false;
        locationFetched = false;
      });
    }
  }

  Widget _buildLocationDisplay() {
    if (!locationFetched) {
      return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: isLocationButtonLoading ? null : _getCurrentLocation,
          child: isLocationButtonLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Check Location'),
        ),
      );
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

  Future<void> _verifyPhone() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() {
      isVerifyingPhone = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.currentUser
              ?.updatePhoneNumber(credential);
          setState(() {
            isPhoneVerified = true;
            isVerifyingPhone = false;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isVerifyingPhone = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification failed')),
          );
        },
        codeSent: (String vId, int? resendToken) {
          setState(() {
            verificationId = vId;
            isOtpSent = true;
            isVerifyingPhone = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent successfully')),
          );
        },
        codeAutoRetrievalTimeout: (String vId) {
          setState(() {
            verificationId = vId;
            isVerifyingPhone = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        isVerifyingPhone = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending OTP')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (otpController.text.isEmpty || verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() {
      isVerifyingPhone = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text,
      );

      await FirebaseAuth.instance.currentUser?.updatePhoneNumber(credential);

      setState(() {
        isPhoneVerified = true;
        isVerifyingPhone = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number verified successfully')),
      );
    } catch (e) {
      setState(() {
        isVerifyingPhone = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  Widget _buildPhoneVerificationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Verification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (!isPhoneVerified) ...[
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+1234567890',
                ),
                keyboardType: TextInputType.phone,
                enabled: !isOtpSent,
              ),
              SizedBox(height: 8),
              if (!isOtpSent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: isVerifyingPhone ? null : _verifyPhone,
                    child: isVerifyingPhone
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Send OTP'),
                  ),
                ),
              if (isOtpSent) ...[
                SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter OTP',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: isVerifyingPhone ? null : _verifyOTP,
                        child: isVerifyingPhone
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text('Verify OTP'),
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: isVerifyingPhone ? null : _verifyPhone,
                      child: Text('Resend OTP'),
                    ),
                  ],
                ),
              ],
            ] else
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Phone Verified',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _storeUserData() async {
    if (widget.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      final userData = {
        'uid': widget.user!.uid,
        'name': widget.name,
        'email': widget.email,
        'imgUrl': widget.imgUrl,
        'location': '$area, $state',
        'bloodGroup': bloodType,
        'dob': selectedDate?.toIso8601String(),
        'phoneNumber': phoneController.text,
        'isPhoneVerified': isPhoneVerified,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await usersCollection
          .doc(widget.user!.uid)
          .set(userData, SetOptions(merge: true));

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile. Please try again.')),
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
            _buildPhoneVerificationCard(),
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
                    _buildLocationDisplay(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (isAgeVerified &&
                          bloodType != null &&
                          locationFetched &&
                          isPhoneVerified)
                      ? _storeUserData
                      : null,
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16),
            if (!(isAgeVerified &&
                bloodType != null &&
                locationFetched &&
                isPhoneVerified))
              Card(
                elevation: 0,
                color: Colors.grey[100],
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required to continue:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      if (!isAgeVerified)
                        Text('• Age verification (must be 18+)'),
                      if (bloodType == null) Text('• Select blood type'),
                      if (!locationFetched) Text('• Location verification'),
                      if (!isPhoneVerified) Text('• Phone number verification'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
