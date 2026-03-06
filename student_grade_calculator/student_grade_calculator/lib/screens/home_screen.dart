import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student.dart';
import '../services/excel_service.dart';
import '../widgets/grade_summary_card.dart';
import '../widgets/student_table.dart';
import '../widgets/upload_zone.dart';
import '../widgets/grading_legend.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Student> _students = [];
  List<String> _errors = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _uploadedFileName;
  String? _savedFilePath;
  String _subjectName = 'Subject';
  final _subjectController = TextEditingController(text: 'Subject');

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errors = [];
      _students = [];
      _savedFilePath = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() {
          _isLoading = false;
          _errors = ['Could not read file bytes. Please try again.'];
        });
        return;
      }

      final parsed = await ExcelService.parseExcelFile(
        bytes,
        subject: _subjectName,
      );

      setState(() {
        _students = parsed['students'] as List<Student>;
        _errors = parsed['errors'] as List<String>;
        _uploadedFileName = file.name;
        _isLoading = false;
      });

      if (_students.isEmpty && _errors.isEmpty) {
        setState(() {
          _errors = ['No valid student data found. Please check your file format.'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errors = ['Error: ${e.toString()}'];
      });
    }
  }

  Future<void> _generateReport() async {
    if (_students.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _savedFilePath = null;
    });

    try {
      final bytes = await ExcelService.generateGradeReport(
        _students,
        subject: _subjectName,
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'grade_report_${_subjectName.replaceAll(' ', '_')}_$timestamp.xlsx';
      final path = await ExcelService.saveFile(bytes, fileName);

      setState(() {
        _savedFilePath = path;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Report saved to: $path')),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errors = [..._errors, 'Failed to generate report: ${e.toString()}'];
      });
    }
  }

  Future<void> _shareReport() async {
    if (_savedFilePath == null) return;

    try {
      await Share.shareXFiles(
        [XFile(_savedFilePath!)],
        text: 'Student Grade Report - $_subjectName',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share file: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _students = [];
      _errors = [];
      _uploadedFileName = null;
      _savedFilePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = _students.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Student Grade Calculator',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          if (hasData)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, color: Colors.white70, size: 18),
              label: const Text('Reset', style: TextStyle(color: Colors.white70)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject input + upload
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject name field
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject Name',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF1A237E),
                            fontWeight: FontWeight.w600,
                          )),
                      const Gap(8),
                      TextField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Mathematics',
                          prefixIcon: const Icon(Icons.book_outlined,
                              color: Color(0xFF1A237E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF1A237E), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (v) =>
                            setState(() => _subjectName = v.isEmpty ? 'Subject' : v),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                // Upload zone
                Expanded(
                  flex: 3,
                  child: UploadZone(
                    fileName: _uploadedFileName,
                    isLoading: _isLoading,
                    onTap: _pickFile,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            const Gap(20),

            // Grading legend
            const GradingLegend().animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const Gap(20),

            // Errors
            if (_errors.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.red.shade700, size: 18),
                        const Gap(8),
                        Text('Warnings / Errors',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    const Gap(8),
                    ..._errors.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('• $e',
                              style: TextStyle(
                                  color: Colors.red.shade800, fontSize: 13)),
                        )),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

            if (_errors.isNotEmpty) const Gap(20),

            // Results
            if (hasData) ...[
              // Summary cards
              GradeSummaryCard(students: _students)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .slideY(begin: 0.1),

              const Gap(20),

              // Student table
              StudentTable(students: _students)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1),

              const Gap(24),

              // Generate button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded, size: 22),
                  label: Text(
                    _isGenerating ? 'Generating...' : 'Generate Grade Report (.xlsx)',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              if (_savedFilePath != null) ...[
                const Gap(16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green.shade700, size: 18),
                            const Gap(8),
                            Text('Report Generated Successfully!',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                      const Gap(12),
                      ElevatedButton.icon(
                        onPressed: _shareReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Download/Share Report'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ],

              const Gap(40),
            ],

            // Empty state
            if (!hasData && !_isLoading && _errors.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Gap(40),
                    Icon(Icons.upload_file_outlined,
                        size: 80, color: Colors.grey.shade300),
                    const Gap(16),
                    Text(
                      'Upload an Excel file to get started',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 16),
                    ),
                    const Gap(8),
                    Text(
                      'File should have columns: Student Name, Marks',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
