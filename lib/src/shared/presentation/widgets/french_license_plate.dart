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
    _focusNode.addListener(() {
      setState(() {});
    });

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
    return text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9\-]'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 0.5),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Carré bleu gauche avec symbole européen
                    Container(
                      width: 38,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Cercle d'étoiles dorées (symbole européen)
                          SizedBox(
                            width: 26,
                            height: 26,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                for (int i = 0; i < 12; i++)
                                  Transform.rotate(
                                    angle: (i * 30) * 3.14159 / 180,
                                    child: Transform.translate(
                                      offset: const Offset(0, -10),
                                      child: const Text(
                                        '★',
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 6,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Lettre F pour France
                          const Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Zone de texte
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled && !widget.isLoading,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Colors.black,
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return TextEditingValue(
                              text: _formatPlateText(newValue.text),
                              selection: TextSelection.collapsed(
                                offset: _formatPlateText(newValue.text).length,
                              ),
                            );
                          }),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'AA-123-BB',
                          hintStyle: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Color(0xFFAAAAAA),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                      ),
                    ),
                    // Carré bleu droit
                    Container(
                      width: 38,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                // Indicateur de chargement
                if (widget.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),
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
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
