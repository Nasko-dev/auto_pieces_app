import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class YannkoWelcomePage extends StatelessWidget {
  const YannkoWelcomePage({super.key});

  // Couleurs (eyedrop approximatifs du visuel)
  static const _bg = Color(0xFF0C1F2F); // bleu nuit
  static const _orange = Color(0xFFFFB129); // bouton "Pièce occasion"
  static const _textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Base maquette ≈ 390x844 (iPhone 13/14), scaling proportionnel
    final s = size.width / 390.0;

    TextStyle h1(double f) => GoogleFonts.inter(
      fontSize: f * s,
      fontWeight: FontWeight.w800,
      height: 1.0,
      color: _textPrimary,
      letterSpacing: -0.5 * s,
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: _bg,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 32 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Titre principal
                    Text(
                      'Pièces Auto',
                      style: h1(48),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12 * s),

                    // Bouton "Pièce occasion"
                    _YButton(
                      color: _orange,
                      label: 'Pièce occasion',
                      icon: Icons.settings,
                      scale: s,
                      onTap: () {
                        // Naviguer vers la page de connexion pour les pièces d'occasion
                        context.go('/welcome');
                      },
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Illustration scooter, ancrée en bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 8 * s,
              child: IgnorePointer(
                child: Center(
                  child: Image.asset(
                    'assets/images/cheetah_delivery.png',
                    height: 270 * s,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YButton extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  const _YButton({
    required this.color,
    required this.label,
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600 * s),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(22 * s),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 72 * s,
            padding: EdgeInsets.symmetric(horizontal: 18 * s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Carré blanc avec l'icône
                Container(
                  width: 48 * s,
                  height: 48 * s,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12 * s),
                  ),
                  child: Icon(icon, size: 28 * s, color: color),
                ),
                SizedBox(width: 16 * s),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 26 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2 * s,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}