import 'package:flutter/material.dart';

class ChatInputWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton Caméra
            _buildActionButton(
              icon: Icons.camera_alt_outlined,
              onPressed: onCamera,
              tooltip: 'Prendre une photo',
            ),

            const SizedBox(width: 8),

            // Zone de saisie de texte
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6), // Gris Instagram
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && !isLoading) {
                      onSend(value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Bouton Galerie
            _buildActionButton(
              icon: Icons.photo_library_outlined,
              onPressed: onGallery,
              tooltip: 'Choisir dans la galerie',
            ),

            const SizedBox(width: 8),

            // Bouton Offre
            _buildActionButton(
              icon: Icons.add_circle_outline,
              onPressed: onOffer,
              tooltip: 'Faire une offre',
              isPrimary: true,
            ),

            const SizedBox(width: 8),

            // Bouton d'envoi
            Container(
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
                  onTap: isLoading ? null : () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      onSend(text);
                    }
                  },
                  child: Center(
                    child: isLoading
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
        color: isPrimary
            ? const Color(0xFF34C759) // Vert pour l'offre
            : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isPrimary
              ? const Color(0xFF34C759)
              : Colors.grey.shade300,
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
              color: isPrimary
                  ? Colors.white
                  : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}