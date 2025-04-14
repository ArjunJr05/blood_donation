import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood/error%20handling/error.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class HRResumeScreen extends StatefulWidget {
  @override
  _HRResumeScreenState createState() => _HRResumeScreenState();
}

class _HRResumeScreenState extends State<HRResumeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  Stream<List<Map<String, dynamic>>>? _applicationsStream;

  @override
  void initState() {
    super.initState();
    _setupApplicationsStream();
  }

  void _setupApplicationsStream() {
    _applicationsStream = supabase
        .from('applications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  String _getResumeNameFromUrl(String? url) {
    if (url == null) return 'No resume uploaded';
    try {
      final uri = Uri.parse(url);
      final fileName = path.basename(uri.path);
      // Remove timestamp and email from filename if present
      final nameParts = fileName.split('_');
      return nameParts.length > 2 ? nameParts.sublist(1).join('_') : fileName;
    } catch (e) {
      return 'Resume file';
    }
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final resumeName = _getResumeNameFromUrl(application["resume_url"]);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application["applicant_email"] ?? "Unknown",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Resume: $resumeName",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(application["status"]),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Applied for: ${application["role"]}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  "Applied: ${_formatDate(application["created_at"])}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildResumeButton(application["resume_url"]),
            SizedBox(height: 16),
            if (application["status"] == "Pending")
              _buildActionButtons(application["id"]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Pending':
        chipColor = Colors.orange;
        break;
      case 'Approved':
        chipColor = Colors.green;
        break;
      case 'Rejected':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: chipColor.withOpacity(0.2),
      labelStyle: TextStyle(color: chipColor),
    );
  }

  Widget _buildResumeButton(String? resumeUrl) {
    return ElevatedButton(
      onPressed: () async {
        if (resumeUrl != null) {
          final uri = Uri.parse(resumeUrl);
          if (await canLaunch(uri.toString())) {
            await launch(uri.toString());
          } else {
            ErrorService.showError(context, 'Could not launch resume URL');
          }
        }
      },
      child: Text('View Resume'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF777DF1),
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildActionButtons(String applicationId) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                _updateApplicationStatus(applicationId, 'Approved'),
            child: Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                _updateApplicationStatus(applicationId, 'Rejected'),
            child: Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateApplicationStatus(
      String applicationId, String status) async {
    try {
      await supabase
          .from('applications')
          .update({'status': status}).eq('id', applicationId);
      ErrorService.showSuccess(
          context, 'Application status updated to $status');
    } catch (e) {
      ErrorService.showError(context, 'Error updating application status: $e');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "Unknown";
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Applicant Resumes"),
        backgroundColor: Color(0xFF777DF1),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _applicationsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF777DF1)),
              ),
            );
          }

          final applications = snapshot.data!;

          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No applications to review",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "New applications will appear here",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              return _buildApplicationCard(application);
            },
          );
        },
      ),
    );
  }
}
