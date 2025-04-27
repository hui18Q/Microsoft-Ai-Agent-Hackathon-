import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/application_details.dart';

class AutoFillScreen extends StatefulWidget {
  final ApplicationDetails applicationDetails;

  const AutoFillScreen({
    Key? key,
    required this.applicationDetails,
  }) : super(key: key);

  @override
  State<AutoFillScreen> createState() => _AutoFillScreenState();
}

class _AutoFillScreenState extends State<AutoFillScreen> {
  bool _isFullScreen = false;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isPdfGenerating = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _nricController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _incomeController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDocument();
  }

  void _initializeControllers() {
    try {
      _fullNameController = TextEditingController(text: widget.applicationDetails.fullName);
      _nricController = TextEditingController(text: widget.applicationDetails.nricNumber);
      _contactController = TextEditingController(text: widget.applicationDetails.contactNumber);
      _addressController = TextEditingController(text: widget.applicationDetails.address);
      _incomeController = TextEditingController(text: widget.applicationDetails.monthlyIncome.toString());
    } catch (e) {
      debugPrint('Error initializing controllers: $e');
      // Show error snackbar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading application details'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _loadDocument() async {
    try {
      // Simulate document loading
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading document: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nricController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _generateAndPrintDocument() async {
    if (_isPdfGenerating) return;

    setState(() {
      _isPdfGenerating = true;
    });

    try {
      final pdf = pw.Document();

      // Add custom font
      final font = await PdfGoogleFonts.interRegular();
      final boldFont = await PdfGoogleFonts.interBold();

      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(
            base: font,
            bold: boldFont,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text(
                    'Aid Application Form',
                    style: pw.TextStyle(
                      fontSize: 24,
                      font: boldFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Personal Information:',
                  style: pw.TextStyle(fontSize: 16, font: boldFont),
                ),
                pw.SizedBox(height: 10),
                _buildPdfField('Full Name', _fullNameController.text),
                _buildPdfField('NRIC/Passport', _nricController.text),
                _buildPdfField('Contact Number', _contactController.text),
                _buildPdfField('Address', _addressController.text),
                _buildPdfField('Monthly Income', 'RM ${_incomeController.text}'),
                _buildPdfField('Aid Type', widget.applicationDetails.aidType),
                
                pw.SizedBox(height: 20),
                pw.Text(
                  'Declaration:',
                  style: pw.TextStyle(fontSize: 16, font: boldFont),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'I hereby declare that all the information provided above is true and accurate to the best of my knowledge.',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Signature: _________________'),
                        pw.SizedBox(height: 10),
                        pw.Text('Date: _________________'),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error generating PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPdfGenerating = false;
        });
      }
    }
  }

  pw.Widget _buildPdfField(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xFF757575))),
          pw.SizedBox(height: 4),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
          pw.Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Document Auto-Fill',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading) ...[
            IconButton(
              icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: const Color(0xFF1A237E)),
              onPressed: () {
                setState(() {
                  _isFullScreen = !_isFullScreen;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.print, color: Color(0xFF1A237E)),
              onPressed: _generateAndPrintDocument,
            ),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFBBDEFB),
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : _isEditing
                ? _buildEditForm()
                : _buildDocumentView(),
      ),
      floatingActionButton: !_isLoading
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2196F3),
              child: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _isEditing = false;
                    });
                  }
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2196F3)),
          const SizedBox(height: 20),
          Text(
            'Filling Up Your Document...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aid Application Form',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoSection('Personal Information'),
              _buildInfoField('Full Name', _fullNameController.text),
              _buildInfoField('NRIC/Passport', _nricController.text),
              _buildInfoField('Contact Number', _contactController.text),
              _buildInfoField('Address', _addressController.text),
              _buildInfoField('Monthly Income', 'RM ${_incomeController.text}'),
              _buildInfoField('Aid Type', widget.applicationDetails.aidType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your full name' : null,
                ),
                _buildTextField(
                  controller: _nricController,
                  label: 'NRIC/Passport',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your NRIC/Passport' : null,
                ),
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your contact number' : null,
                ),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your address' : null,
                ),
                _buildTextField(
                  controller: _incomeController,
                  label: 'Monthly Income',
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your monthly income' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
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
              color: Colors.black87,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
        ),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }
} 