import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentationPage extends StatefulWidget {
  const DocumentationPage({super.key});

  @override
  State<DocumentationPage> createState() => _DocumentationPageState();
}

class _DocumentationPageState extends State<DocumentationPage> {
  String _content = '';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadDocumentation();
  }

  Future<void> _loadDocumentation() async {
    try {
      // Load the plain text documentation files
      final summary = await rootBundle.loadString('resourse/Project_Summary_and_Manual.txt');
      final taskMapping = await rootBundle.loadString('resourse/Task_File_Mapping.txt');
      final contributions = await rootBundle.loadString('resourse/Project_Contributions.txt');
      final compliance = await rootBundle.loadString('resourse/Comparison_and_Status.txt');

      if (mounted) {
        setState(() {
          _content = '''╔════════════════════════════════════════════════════════════════╗
║         MINIMART PROJECT DOCUMENTATION                          ║
╚════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════
1. PROJECT SUMMARY & MANUAL
═══════════════════════════════════════════════════════════════════

$summary

═══════════════════════════════════════════════════════════════════
2. TASK & FILE MAPPING
═══════════════════════════════════════════════════════════════════

$taskMapping

═══════════════════════════════════════════════════════════════════
3. PROJECT CONTRIBUTIONS
═══════════════════════════════════════════════════════════════════

$contributions

═══════════════════════════════════════════════════════════════════
4. PROJECT COMPLIANCE STATUS
═══════════════════════════════════════════════════════════════════

$compliance
''';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading documentation: $e');
      if (mounted) {
        setState(() {
          _error = 'Error loading documentation: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B6B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Documentation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_error, textAlign: TextAlign.center),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _content,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Courier',
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ),
    );
  }
}
