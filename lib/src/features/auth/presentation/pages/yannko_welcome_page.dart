import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class YannkoWelcomePage extends StatelessWidget {
  const YannkoWelcomePage({super.key});

  // Couleurs (eyedrop approximatifs du visuel)
  static const _bg = Color(0xFF0C1F2F); // bleu nuit
  static const _green = Color(0xFF2CC36B); // bouton "Pièce neuve"
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
    TextStyle h2(double f) => GoogleFonts.inter(
      fontSize: f * s,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      letterSpacing: -0.2 * s,
    );
    TextStyle body(double f) => GoogleFonts.inter(
      fontSize: f * s,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: _textPrimary.withOpacity(0.92),
    );

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 32 * s),

                  // Logo tête guépard
                  Center(
                    child: Image.asset(
                      'assets/images/cheetah_head.png',
                      height: 112 * s,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) => Icon(
                            Icons.pets_rounded,
                            color: Colors.amber.shade300,
                            size: 96 * s,
                          ),
                    ),
                  ),

                  SizedBox(height: 16 * s),

                  // "Yannko Pièce"
                  Text('Yannko Pièce', style: h2(28)),

                  SizedBox(height: 10 * s),

                  // "Bienvenue"
                  Text('Bienvenue', style: h1(56)),

                  SizedBox(height: 16 * s),

                  // Paragraphe
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    child: Text(
                      "Commandez vos pièces auto neuves et \n"
                      "d'occasion en quelques clics.\n"
                      "Livraison rapide et garantie fiabilité.",
                      textAlign: TextAlign.center,
                      style: body(16),
                    ),
                  ),

                  SizedBox(height: 20 * s),

                  // Bouton "Pièce neuve"
                  _YButton(
                    color: _green,
                    label: 'Pièce neuve',
                    icon: Icons.inventory_2_rounded,
                    scale: s,
                    onTap: () {
                      // Naviguer vers la page de connexion pour les pièces neuves
                      context.go('/welcome');
                    },
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
