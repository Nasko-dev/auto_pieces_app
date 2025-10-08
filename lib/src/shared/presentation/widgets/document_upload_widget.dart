import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String title;
  final List<String> instructions;
  final String? documentUrl;
  final Function(File) onDocumentSelected;
  final bool isRequired;
  final String acceptedFormats;

  const DocumentUploadWidget({
    super.key,
    required this.title,
    required this.instructions,
    this.documentUrl,
    required this.onDocumentSelected,
    this.isRequired = true,
    this.acceptedFormats = 'JPG, PNG',
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  File? _selectedDocument;
  final ImagePicker _imagePicker = ImagePicker();

  static const _primaryBlue = Color(0xFF007AFF);
  static const _textPrimary = Color(0xFF1D1D1F);
  static const _textSecondary = Color(0xFF8E8E93);
  static const _fieldBg = Color(0xFFF2F2F7);
  static const _borderColor = Color(0xFFD1D1D6);
  static const _successGreen = Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 390.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Row(
          children: [
            Text(
              widget.title,
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                letterSpacing: -0.2 * s,
              ),
            ),
            if (widget.isRequired) ...[
              SizedBox(width: 4 * s),
              Text(
                '*',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: 12 * s),

        // Conteneur d'instructions et d'upload
        Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: _fieldBg,
            borderRadius: BorderRadius.circular(12 * s),
            border: Border.all(
              color: _selectedDocument != null ? _successGreen : _borderColor,
              width: _selectedDocument != null ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions
              ...widget.instructions.map((instruction) {
                final isEmoji = instruction.startsWith('📸') ||
                                instruction.startsWith('📄') ||
                                instruction.startsWith('✓');
                return Padding(
                  padding: EdgeInsets.only(bottom: 8 * s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isEmoji) ...[
                        Text(
                          instruction.substring(0, 2),
                          style: TextStyle(fontSize: 16 * s),
                        ),
                        SizedBox(width: 8 * s),
                        Expanded(
                          child: Text(
                            instruction.substring(2).trim(),
                            style: GoogleFonts.inter(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w500,
                              color: _textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: Text(
                            instruction,
                            style: GoogleFonts.inter(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w500,
                              color: _textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              SizedBox(height: 16 * s),

              // Preview ou bouton d'upload
              if (_selectedDocument != null)
                _buildDocumentPreview(s)
              else
                _buildUploadButton(s),

              // Formats acceptés
              if (_selectedDocument == null) ...[
                SizedBox(height: 12 * s),
                Center(
                  child: Text(
                    'Formats acceptés : ${widget.acceptedFormats}',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                      color: _textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(double scale) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showImageSourceOptions,
        icon: Icon(
          Icons.upload_file_rounded,
          size: 20 * scale,
          color: _primaryBlue,
        ),
        label: Text(
          'Choisir un document',
          style: GoogleFonts.inter(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: BorderSide(color: _primaryBlue, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 14 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10 * scale),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: _successGreen, width: 2.0),
      ),
      child: Row(
        children: [
          // Icon de succès
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: _successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              Icons.check_circle,
              color: _successGreen,
              size: 24 * scale,
            ),
          ),

          SizedBox(width: 12 * scale),

          // Info document
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document ajouté',
                  style: GoogleFonts.inter(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: _successGreen,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  _selectedDocument!.path.split('/').last,
                  style: GoogleFonts.inter(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 8 * scale),

          // Boutons d'action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _showImageSourceOptions,
                icon: Icon(
                  Icons.edit_outlined,
                  color: _primaryBlue,
                  size: 20 * scale,
                ),
                padding: EdgeInsets.all(8 * scale),
                constraints: BoxConstraints(
                  minWidth: 36 * scale,
                  minHeight: 36 * scale,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDocument = null;
                  });
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 20 * scale,
                ),
                padding: EdgeInsets.all(8 * scale),
                constraints: BoxConstraints(
                  minWidth: 36 * scale,
                  minHeight: 36 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final s = size.width / 390.0;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40 * s,
                  height: 4 * s,
                  decoration: BoxDecoration(
                    color: _textSecondary,
                    borderRadius: BorderRadius.circular(2 * s),
                  ),
                ),
                SizedBox(height: 20 * s),
                Text(
                  'Choisir une source',
                  style: GoogleFonts.inter(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 24 * s),
                Row(
                  children: [
                    // Appareil photo
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _selectImageSource(ImageSource.camera);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20 * s),
                          decoration: BoxDecoration(
                            color: _fieldBg,
                            borderRadius: BorderRadius.circular(16 * s),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16 * s),
                                decoration: BoxDecoration(
                                  color: _primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50 * s),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: _primaryBlue,
                                  size: 32 * s,
                                ),
                              ),
                              SizedBox(height: 12 * s),
                              Text(
                                'Appareil photo',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * s,
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16 * s),
                    // Galerie
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _selectImageSource(ImageSource.gallery);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20 * s),
                          decoration: BoxDecoration(
                            color: _fieldBg,
                            borderRadius: BorderRadius.circular(16 * s),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16 * s),
                                decoration: BoxDecoration(
                                  color: _primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(50 * s),
                                ),
                                child: Icon(
                                  Icons.photo_library,
                                  color: _primaryBlue,
                                  size: 32 * s,
                                ),
                              ),
                              SizedBox(height: 12 * s),
                              Text(
                                'Galerie',
                                style: GoogleFonts.inter(
                                  fontSize: 14 * s,
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * s),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectImageSource(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedDocument = file;
        });
        widget.onDocumentSelected(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection du document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
