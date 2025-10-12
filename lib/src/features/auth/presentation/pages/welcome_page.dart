import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/particulier_auth_providers.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../controllers/particulier_auth_controller.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  // Couleurs du design Yannko
  static const _bg = Color(0xFF0C1F2F); // bleu nuit
  static const _green = Color(0xFF2CC36B); // bouton Particulier
  static const _orange = Color(0xFFFFB129); // bouton Professionnel
  static const _textPrimary = Colors.white;
  static const _primaryBlue = Color(0xFF007AFF); // iOS blue

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 390.0;

    TextStyle h1(double f) => GoogleFonts.inter(
          fontSize: f * s,
          fontWeight: FontWeight.w800,
          height: 1.0,
          color: _textPrimary,
          letterSpacing: -0.5 * s,
        );

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Contenu principal
          SafeArea(
            child: Padding(
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
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.pets_rounded,
                        color: Colors.amber.shade300,
                        size: 96 * s,
                      ),
                    ),
                  ),

                  SizedBox(height: 16 * s),

                  SizedBox(height: 10 * s),

                  // "Yannko OCCASION"
                  Center(
                    child: Text(
                      'Yannko OCCASION',
                      style: h1(46).copyWith(
                          color: const Color.fromARGB(255, 241, 193, 33)),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 16 * s),

                  // Description
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * s),
                      child: Text(
                        'Ici, vous pouvez trouvez trouver vos piéces doccasion en quelques segonde',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w400,
                          color: _textPrimary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Boutons centrés
                  Center(
                    child: Column(
                      children: [
                        // Boutons côte à côte
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bouton Particulier
                            Expanded(
                              child: _YButtonCompact(
                                color: _green,
                                label: 'Particulier',
                                icon: Icons.person,
                                scale: s,
                                onTap: () => _loginAsParticulier(ref, context),
                              ),
                            ),

                            SizedBox(width: 12 * s),

                            // Bouton Professionnel
                            Expanded(
                              child: _YButtonCompact(
                                color: _orange,
                                label: 'Professionnel',
                                icon: Icons.store,
                                scale: s,
                                onTap: () => _goToSellerLogin(context),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16 * s),

                        // Bouton "Première fois ici ?" - pleine largeur
                        SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20 * s),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _showInfoDialog(context, s),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20 * s,
                                  vertical: 16 * s,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      color: Colors.white,
                                      size: 22 * s,
                                    ),
                                    SizedBox(width: 10 * s),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Première fois ici ?',
                                            style: GoogleFonts.inter(
                                              fontSize: 15 * s,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 3 * s),
                                          Text(
                                            'Comprenez quelle est la différence entre particulier et professionnel',
                                            style: GoogleFonts.inter(
                                              fontSize: 11 * s,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withValues(alpha: 0.95),
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

          // Bouton retour iOS
          Positioned(
            top: MediaQuery.of(context).padding.top + 8 * s,
            left: 16 * s,
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: _primaryBlue,
                size: 28,
              ),
              onPressed: () {
                HapticHelper.light();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else if (context.mounted) {
                  context.go('/');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, double s) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const _InfoPage(),
      ),
    );
  }

  void _loginAsParticulier(WidgetRef ref, BuildContext context) async {
    await ref
        .read(particulierAuthControllerProvider.notifier)
        .signInAnonymously();

    // Redirection après connexion réussie
    if (context.mounted) {
      final state = ref.read(particulierAuthControllerProvider);
      if (state.isAuthenticated) {
        context.go('/home');
      }
    }
  }

  void _goToSellerLogin(BuildContext context) {
    context.push('/seller/login');
  }
}

// Widget carte d'information
class _InfoCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final String description;
  final double scale;

  const _InfoCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.description,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10 * s),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12 * s),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24 * s,
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6 * s),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget bouton compact côte à côte (sans sous-titre)
class _YButtonCompact extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  const _YButtonCompact({
    required this.color,
    required this.label,
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20 * s),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * s,
            vertical: 20 * s,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône
              Container(
                width: 56 * s,
                height: 56 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16 * s),
                ),
                child: Icon(icon, size: 32 * s, color: color),
              ),
              SizedBox(height: 12 * s),
              // Label
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2 * s,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page d'information pleine page
class _InfoPage extends StatelessWidget {
  const _InfoPage();

  static const _bg = Color(0xFF0C1F2F);
  static const _green = Color(0xFF2CC36B);
  static const _orange = Color(0xFFFFB129);
  static const _textPrimary = Colors.white;
  static const _primaryBlue = Color(0xFF007AFF); // iOS blue

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 390.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20 * s),

              // Bouton retour iOS + titre
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: _primaryBlue,
                      size: 28,
                    ),
                    onPressed: () {
                      HapticHelper.light();
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 8 * s),
                  Expanded(
                    child: Text(
                      'Comprendre la différence',
                      style: GoogleFonts.inter(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32 * s),

              // Description
              Text(
                'Choisissez le profil qui correspond à vos besoins',
                style: GoogleFonts.inter(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w400,
                  color: _textPrimary.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),

              SizedBox(height: 32 * s),

              // Carte Particulier
              _InfoCard(
                title: 'Particulier',
                color: _green,
                icon: Icons.person,
                description: 'Vous recherchez des pièces automobiles d\'occasion pour réparer ou entretenir votre véhicule.',
                scale: s,
              ),

              SizedBox(height: 20 * s),

              // Carte Professionnel
              _InfoCard(
                title: 'Professionnel',
                color: _orange,
                icon: Icons.store,
                description: 'Vous êtes un vendeur de pièces automobiles et souhaitez proposer vos produits à nos utilisateurs.',
                scale: s,
              ),

              const Spacer(),

              // Bouton "J'ai compris"
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: _green,
                  borderRadius: BorderRadius.circular(16 * s),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16 * s),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16 * s),
                      alignment: Alignment.center,
                      child: Text(
                        'J\'ai compris',
                        style: GoogleFonts.inter(
                          fontSize: 16 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24 * s),
            ],
          ),
        ),
      ),
    );
  }
}
