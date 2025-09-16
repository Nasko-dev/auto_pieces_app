import 'package:flutter/material.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final VoidCallback? onOffer;
  final bool isLoading;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    this.onCamera,
    this.onGallery,
    this.onOffer,
    this.isLoading = false,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Center(
          child: Container(
            width: screenWidth * 0.95, // 80% de la largeur de l'écran
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Bouton Caméra (toujours visible)
                  _buildActionButton(
                    icon: Icons.camera_alt_outlined,
                    onPressed: widget.onCamera,
                    tooltip: 'Prendre une photo',
                  ),

                  const SizedBox(width: 6),

                  // Zone de saisie de texte
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty && !widget.isLoading) {
                          widget.onSend(value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Boutons conditionnels selon l'état du texte
                  if (!_hasText) ...[
                    // Mode sans texte : Galerie + Offre
                    _buildActionButton(
                      icon: Icons.photo_library_outlined,
                      onPressed: widget.onGallery,
                      tooltip: 'Choisir dans la galerie',
                    ),

                    const SizedBox(width: 6),

                    if (widget.onOffer != null) ...[
                      _buildActionButton(
                        icon: Icons.add_circle_outline,
                        onPressed: widget.onOffer,
                        tooltip: 'Faire une offre',
                        isPrimary: true,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],

                  // Bouton d'envoi (visible seulement quand il y a du texte)
                  if (_hasText || widget.isLoading) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B82F6), // Bleu Instagram
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: !widget.isLoading ? () {
                            final text = widget.controller.text.trim();
                            if (text.isNotEmpty) {
                              widget.onSend(text);
                            }
                          } : null,
                          child: Center(
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            isPrimary
                ? const Color(0xFF34C759) // Vert pour l'offre
                : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isPrimary ? const Color(0xFF34C759) : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
