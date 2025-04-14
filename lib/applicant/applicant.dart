// ignore_for_file: prefer_const_constructors

import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood/error%20handling/error.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ApplicantPage extends StatefulWidget {
  @override
  _ApplicantPageState createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  File? _resume;
  final picker = ImagePicker();
  String? _appliedRole;
  List<Map<String, dynamic>> _myApplications = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> jobVacancies = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _loadMyApplications();
  }

  Future<void> _loadJobs() async {
    try {
      final response = await supabase
          .from('jobs')
          .select()
          .eq('status', 'Active')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          jobVacancies = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorService.showError(context, 'Error loading jobs: $e');
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadJobs();
    await _loadMyApplications();
  }

  Future<void> _pickResume(String role) async {
    if (_myApplications.any((app) => app['role'] == role)) {
      ErrorService.showError(
          context, 'You have already applied for this position');
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _resume = File(pickedFile.path);
        _appliedRole = role;
      });
      await _uploadResumeAndCreateApplication(pickedFile.path, role);
    }
  }

  Future<void> _loadMyApplications() async {
    try {
      final response = await supabase
          .from('applications')
          .select()
          .eq('applicant_email', supabase.auth.currentUser?.email as Object);

      if (mounted) {
        setState(() {
          _myApplications = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorService.showError(context, 'Error loading applications: $e');
      }
    }
  }

  Future<void> _uploadResumeAndCreateApplication(
      String filePath, String role) async {
    setState(() => _isLoading = true);

    try {
      final userEmail = supabase.auth.currentUser?.email;
      if (userEmail == null) throw Exception('User not logged in');

      final fileExt = path.extension(filePath);
      final fileName = '${DateTime.now().toIso8601String()}_$userEmail$fileExt';

      // First try to list buckets to check if storage is accessible
      try {
        final buckets = await supabase.storage.listBuckets();
        print('Available buckets: ${buckets.map((b) => b.name).join(', ')}');
      } catch (e) {
        print('Error listing buckets: $e');
      }

      // Try the upload
      try {
        await supabase.storage.from('resumes').upload(fileName, _resume!);
      } catch (e) {
        print('Upload error details: $e');
        throw Exception('Unable to upload resume. Error: $e');
      }

      final fileUrl = supabase.storage.from('resumes').getPublicUrl(fileName);

      await supabase.from('applications').insert({
        'applicant_email': userEmail,
        'role': role,
        'resume_url': fileUrl,
        'status': 'Pending',
        // Remove the applied_at field as it will be automatically set by the database
      });

      await _loadMyApplications();
      _showSubmissionMessage();
    } catch (e) {
      if (mounted) {
        ErrorService.showError(context, 'Error submitting application: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSubmissionMessage() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text("Application Submitted",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your application has been successfully submitted to HR.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              "We'll review your application and get back to you soon.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(fontSize: 16)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );

    // Auto dismiss after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  Widget _buildSkillChip(String skill) {
    return Chip(
      label:
          Text(skill, style: TextStyle(color: Color(0xFF777DF1), fontSize: 12)),
      backgroundColor: Colors.blue[50],
      padding: EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.business_center,
              size: 64,
              color: Colors.red[300],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "No Positions Available",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "We're not hiring at the moment. Please check back later for new opportunities!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "We'll notify you when new positions are available!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.notifications_active_outlined),
            label: Text("Notify Me When Hiring"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF777DF1),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHiring = jobVacancies.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 244, 244),
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Open Positions",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              "${jobVacancies.length} positions available",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF777DF1),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Chip(
              label: Text(
                isHiring ? "Now Hiring" : "Not Hiring",
                style: TextStyle(
                  color: isHiring ? Colors.green[700] : Colors.red[700],
                ),
              ),
              backgroundColor: isHiring ? Colors.green[50] : Colors.red[50],
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        child: isHiring
            ? ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: jobVacancies.length,
                itemBuilder: (context, index) {
                  var job = jobVacancies[index];
                  bool isApplied =
                      _myApplications.any((app) => app['role'] == job['role']);

                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job['role'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          job['department'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          job['location'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFF777DF1),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(Icons.work_outline,
                                      size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(job['mode'],
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                  SizedBox(width: 16),
                                  Icon(Icons.timer_outlined,
                                      size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(job['experience'],
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Required Skills",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (job['skills'] as List)
                                    .map((skill) =>
                                        _buildSkillChip(skill.toString()))
                                    .toList(),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Overview",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                job['overview'],
                                style: TextStyle(
                                    color: Colors.grey[600], height: 1.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Responsibilities",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                job['responsibilities'],
                                style: TextStyle(
                                    color: Colors.grey[600], height: 1.5),
                              ),
                              SizedBox(height: 20),
                              if (isApplied)
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Application Submitted",
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Status: Under Review",
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => _pickResume(job['role']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF777DF1),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.upload_file, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                "Apply Now",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : _buildEmptyState(),
      ),
    );
  }
}
