import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quote_item.dart';
import '../services/gemini_service.dart';
import '../widgets/file_upload_widget.dart';
import '../widgets/email_type_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _inspectionFile;
  File? _quoteFile;
  EmailType _selectedEmailType = EmailType.standardProfessional;

  List<QuoteItem> _quantities = [];
  String _emailContent = '';

  bool _isLoadingQuantities = false;
  bool _isLoadingEmail = false;
  bool _emailCopied = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    GeminiService.initialize();
  }

  void _clearError() {
    setState(() {
      _errorMessage = '';
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> _generateQuantities() async {
    if (_inspectionFile == null) {
      _showError('Please upload an inspection document first.');
      return;
    }

    setState(() {
      _isLoadingQuantities = true;
      _quantities = [];
    });
    _clearError();

    try {
      final result =
          await GeminiService.generateQuantitiesFromDocument(_inspectionFile!);
      setState(() {
        _quantities = result;
      });
    } catch (e) {
      _showError('Failed to generate quantities: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingQuantities = false;
      });
    }
  }

  Future<void> _generateEmail() async {
    if (_quoteFile == null) {
      _showError('Please upload a final quote document first.');
      return;
    }

    setState(() {
      _isLoadingEmail = true;
      _emailContent = '';
      _emailCopied = false;
    });
    _clearError();

    try {
      final result = await GeminiService.generateEmailFromQuote(
          _quoteFile!, _selectedEmailType);
      setState(() {
        _emailContent = result.emailBody;
      });
    } catch (e) {
      _showError('Failed to generate email: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingEmail = false;
      });
    }
  }

  Future<void> _copyEmail() async {
    if (_emailContent.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _emailContent));
      setState(() {
        _emailCopied = true;
      });

      // Reset the copied state after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _emailCopied = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: const Text(
                        'Sales Quote Assistant',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Automate your sales workflow with AI-powered document processing.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: colorScheme.error,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _errorMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Main content
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 768) {
                    // Desktop layout - two columns
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildQuantitiesSection(theme, colorScheme)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildEmailSection(theme, colorScheme)),
                      ],
                    );
                  } else {
                    // Mobile layout - single column
                    return Column(
                      children: [
                        _buildQuantitiesSection(theme, colorScheme),
                        const SizedBox(height: 16),
                        _buildEmailSection(theme, colorScheme),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitiesSection(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generate Quote Quantities',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Upload a site inspection document (Word or PDF) to automatically extract and sum up all line items.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            FileUploadWidget(
              label: 'Upload Inspection Document',
              acceptedTypes: const ['pdf', 'doc', 'docx'],
              onFileSelected: (file) {
                setState(() {
                  _inspectionFile = file;
                });
              },
              selectedFile: _inspectionFile,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_inspectionFile == null || _isLoadingQuantities)
                  ? null
                  : _generateQuantities,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isLoadingQuantities
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.calculate),
              label: Text(
                _isLoadingQuantities ? 'Generating...' : 'Generate Quantities',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (_quantities.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Extracted Items:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Item Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total Quantity',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: _quantities
                        .map(
                          (item) => DataRow(
                            cells: [
                              DataCell(Text(item.name)),
                              DataCell(
                                Text(
                                  item.totalQuantity.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSection(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Create New Email',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Upload the completed quote (PDF) to generate a professional email template to send to your client.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Select an email tone:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            EmailTypeSelector(
              selectedType: _selectedEmailType,
              onTypeSelected: (type) {
                setState(() {
                  _selectedEmailType = type;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              '2. Upload the final quote:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FileUploadWidget(
              label: 'Upload Final Quote PDF',
              acceptedTypes: const ['pdf'],
              onFileSelected: (file) {
                setState(() {
                  _quoteFile = file;
                });
              },
              selectedFile: _quoteFile,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_quoteFile == null || _isLoadingEmail)
                  ? null
                  : _generateEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isLoadingEmail
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.email),
              label: Text(
                _isLoadingEmail ? 'Creating...' : 'Create New Email',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (_emailContent.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Email:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _copyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 1,
                    ),
                    icon: Icon(
                      _emailCopied ? Icons.check : Icons.copy,
                      color: _emailCopied ? Colors.green : null,
                      size: 16,
                    ),
                    label: Text(
                      _emailCopied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                        color: _emailCopied ? Colors.green : null,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _emailContent,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
