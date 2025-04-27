import 'package:flutter/material.dart';

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key});

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  String? selectedFilter;
  List<Map<String, dynamic>> applications = [
    {
      'title': 'Bantuan Sara Hidup 2025',
      'id': '123456',
      'status': 'In Progress',
      'date': '28 January 2024',
      'applicant': {
        'name': 'John Doe',
        'nric': '990101-01-1234',
        'phone': '+60123456789',
        'address': '123, Jalan ABC, 12345 Kuala Lumpur',
        'income': 'RM 3,000',
        'occupation': 'Self-employed',
        'dependents': '3',
        'reason': 'Financial assistance for children\'s education'
      }
    },
    // Add more sample applications here
  ];

  List<Map<String, dynamic>> get filteredApplications {
    if (selectedFilter == null) return applications;
    return applications.where((app) => app['status'] == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 250, 250),
      appBar: AppBar(
        title: const Text(
          'Status Update',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for Application ID...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2196F3)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Filter applications by ID
                  applications = applications.where(
                    (app) => app['id'].toString().contains(value),
                  ).toList();
                });
              },
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatusChip('Approved', Colors.green),
                const SizedBox(width: 8),
                _buildStatusChip('In Progress', Colors.orange),
                const SizedBox(width: 8),
                _buildStatusChip('Rejected', Colors.red),
              ],
            ),
          ),

          // Application List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) {
                final application = filteredApplications[index];
                final Color statusColor;
                switch (application['status']) {
                  case 'Approved':
                    statusColor = Colors.green;
                    break;
                  case 'Rejected':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.orange;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildApplicationCard(
                    application['title'],
                    application['id'],
                    application['status'],
                    application['date'],
                    statusColor,
                    application,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    bool isSelected = selectedFilter == label;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      onSelected: (bool selected) {
        setState(() {
          selectedFilter = selected ? label : null;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildApplicationCard(
    String title,
    String id,
    String status,
    String date,
    Color statusColor,
    Map<String, dynamic> applicationData,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $id',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              'Date Submitted: $date',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(applicationData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Update Status'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showApplicationDetails(applicationData),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Application Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Approve'),
                onTap: () {
                  setState(() {
                    application['status'] = 'Approved';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending, color: Colors.orange),
                title: const Text('In Progress'),
                onTap: () {
                  setState(() {
                    application['status'] = 'In Progress';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Reject'),
                onTap: () {
                  setState(() {
                    application['status'] = 'Rejected';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApplicationDetailsScreen(application: application),
      ),
    );
  }
}

class ApplicationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailsScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  double _scale = 1.0;
  bool _isFullScreen = false;
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _updateScale(double newScale) {
    setState(() {
      _scale = newScale.clamp(0.5, 4.0);
      final Matrix4 updatedMatrix = Matrix4.identity()..scale(_scale);
      _transformationController.value = updatedMatrix;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 250, 250),
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  const Text(
                    'ID: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    widget.application['id'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.black,
                  ),
                  onPressed: _toggleFullScreen,
                ),
              ],
            ),
      body: Column(
        children: [
          // Application Form View
          Expanded(
            child: Stack(
              children: [
                InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.5,
                  maxScale: 4.0,
                  onInteractionUpdate: (details) {
                    setState(() {
                      _scale = details.scale;
                    });
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildApplicationFormSection(
                            'Personal Information',
                            [
                              _buildFormField('Full Name', widget.application['applicant']['name']),
                              _buildFormField('NRIC', widget.application['applicant']['nric']),
                              _buildFormField('Phone Number', widget.application['applicant']['phone']),
                              _buildFormField('Address', widget.application['applicant']['address']),
                            ],
                          ),
                          _buildApplicationFormSection(
                            'Financial Information',
                            [
                              _buildFormField('Monthly Income', widget.application['applicant']['income']),
                              _buildFormField('Occupation', widget.application['applicant']['occupation']),
                              _buildFormField('Number of Dependents', widget.application['applicant']['dependents']),
                            ],
                          ),
                          _buildApplicationFormSection(
                            'Application Details',
                            [
                              _buildFormField('Program', widget.application['title']),
                              _buildFormField('Date Submitted', widget.application['date']),
                              _buildFormField('Status', widget.application['status']),
                              _buildFormField('Reason for Application', widget.application['applicant']['reason']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isFullScreen)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit),
                      onPressed: _toggleFullScreen,
                      color: Colors.black,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Bottom Actions Bar
          if (!_isFullScreen)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateScale(_scale - 0.1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${(_scale * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateScale(_scale + 0.1),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // Handle download
                        },
                        tooltip: 'Download Application',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: () {
                          // Handle print
                        },
                        tooltip: 'Print Application',
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationFormSection(String title, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          ...fields,
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
} 