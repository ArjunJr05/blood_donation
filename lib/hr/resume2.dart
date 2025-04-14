import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blood/error%20handling/error.dart';

class PostJobScreen extends StatefulWidget {
  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSubmitted = false;

  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _overviewController = TextEditingController();
  final TextEditingController _responsibilitiesController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedMode;
  String? _selectedDepartment;

  final List<String> modes = ['Full-Time', 'Part-Time', 'Contract'];
  final List<String> departments = [
    'Engineering',
    'Marketing',
    'HR',
    'Sales',
    'Design'
  ];

  @override
  void dispose() {
    _roleController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _overviewController.dispose();
    _responsibilitiesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not authenticated';

      final skills =
          _skillsController.text.split(',').map((e) => e.trim()).toList();
      final jobData = {
        'role': _roleController.text,
        'mode': _selectedMode,
        'experience': _experienceController.text,
        'skills': skills,
        'overview': _overviewController.text,
        'responsibilities': _responsibilitiesController.text,
        'location': _locationController.text,
        'department': _selectedDepartment,
        'posted_by': user.email,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'Active'
      };

      await supabase.from('jobs').insert(jobData);
      if (mounted) {
        ErrorService.showSuccess(context, 'Job posted successfully!');
        setState(() {
          isSubmitted = true;
        });
      }
    } catch (error) {
      if (mounted) {
        ErrorService.showError(context, 'Error posting job: $error');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post New Job'),
        backgroundColor: Color(0xFF777DF1),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 380,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(labelText: 'Job Role'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: InputDecoration(labelText: 'Department'),
                    items: departments.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDepartment = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedMode,
                    decoration: InputDecoration(labelText: 'Mode'),
                    items: modes.map((mode) {
                      return DropdownMenuItem(value: mode, child: Text(mode));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedMode = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _experienceController,
                    decoration:
                        InputDecoration(labelText: 'Required Experience'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _skillsController,
                    decoration: InputDecoration(
                        labelText: 'Required Skills (comma-separated)'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _overviewController,
                    decoration: InputDecoration(labelText: 'Job Overview'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _responsibilitiesController,
                    decoration: InputDecoration(labelText: 'Responsibilities'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _postJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF777DF1),
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Post Job', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
