import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class FrenchLicensePlate extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool enabled;
  final bool isLoading;
  final String? errorText;
  final String? plateNumber;

  const FrenchLicensePlate({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.isLoading = false,
    this.errorText,
    this.plateNumber,
  });

  @override
  State<FrenchLicensePlate> createState() => _FrenchLicensePlateState();
}

class _FrenchLicensePlateState extends State<FrenchLicensePlate> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus listener pour les callbacks si nécessaire
    _focusNode.addListener(() {
      setState(() {});
    });

    // Initialiser le controller avec plateNumber si fourni
    if (widget.plateNumber != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.plateNumber!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _formatPlateText(String text) {
    // Convertir en majuscules et garder uniquement lettres, chiffres et tirets
    return text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\-]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 80, // Hauteur très augmentée pour éviter le rognage
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                // Image de fond de la plaque
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        // Image en arrière-plan
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/french_plate.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        // Contenu par-dessus
                        Container(
                          decoration: const BoxDecoration(
                            // Complètement transparent pour voir l'image
                            color: Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              // Espace pour la bande bleue (invisible car dans l'image)
                              const SizedBox(width: 50),
                              // Zone de texte
                              Expanded(
                                child: TextField(
                                  controller: widget.controller,
                                  focusNode: _focusNode,
                                  enabled: widget.enabled && !widget.isLoading,
                                  textAlign: TextAlign.center,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  style: const TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 8,
                                    color: Colors.black,
                                    height: 1,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(
                                      15,
                                    ), // Permet plus de caractères pour plaques collection
                                    TextInputFormatter.withFunction((
                                      oldValue,
                                      newValue,
                                    ) {
                                      return TextEditingValue(
                                        text: _formatPlateText(newValue.text),
                                        selection: TextSelection.collapsed(
                                          offset:
                                              _formatPlateText(
                                                newValue.text,
                                              ).length,
                                        ),
                                      );
                                    }),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'AA-123-BB',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 29,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 4,
                                      color: Color(0xFFAAAAAA),
                                      height: 1,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: -10,
                                    ),
                                  ),
                                  onChanged: widget.onChanged,
                                  onSubmitted: widget.onSubmitted,
                                ),
                              ),
                              // Espace pour le logo région
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                        // Indicateur de chargement
                        if (widget.isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppTheme.white.withValues(alpha: 0.8),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CupertinoActivityIndicator(
                                    radius: 12,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: AppTheme.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
