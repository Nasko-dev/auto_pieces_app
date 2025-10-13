import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/seller_auth_controller.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/haptic_helper.dart';

class SellerLoginPage extends ConsumerStatefulWidget {
  const SellerLoginPage({super.key});

  @override
  ConsumerState<SellerLoginPage> createState() => _SellerLoginPageState();
}

class _SellerLoginPageState extends ConsumerState<SellerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Couleurs cohérentes avec le design
  static const _bg = Colors.white;
  static const _primaryBlue = Color(0xFF007AFF);
  static const _textPrimary = Color(0xFF1D1D1F);
  static const _textSecondary = Color(0xFF8E8E93);
  static const _fieldBg = Color(0xFFF2F2F7);
  static const _borderColor = Color(0xFFD1D1D6);
  static const _orange = Color(0xFFFF9500);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 390.0;
    
    final authState = ref.watch(sellerAuthControllerProvider);
    
    // Navigation et gestion des états
    ref.listen<SellerAuthState>(sellerAuthControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (seller) {
          // Navigation vers l'accueil vendeur avec un délai pour s'assurer que l'état est bien mis à jour
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/seller/home');
            }
          });
        },
        unauthenticated: () {},
        error: (message) {
          // Affichage de l'erreur
          if (context.mounted) {
            notificationService.error(context, message);
          }
        },
      );
    });

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
      color: _textSecondary,
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticHelper.light();
            context.pop();
          },
          icon: Icon(
            Icons.chevron_left,
            color: _textPrimary,
            size: 24 * s,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20 * s),

                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        color: _primaryBlue,
                        size: 80 * s,
                      ),
                      SizedBox(height: 16 * s),
                      Text('Espace Vendeur', style: h1(32)),
                      SizedBox(height: 8 * s),
                      Text(
                        'Connectez-vous à votre compte vendeur',
                        style: body(16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40 * s),

                // Email
                Text('Email', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  scale: s,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email non valide';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // Mot de passe
                Text('Mot de passe', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Votre mot de passe',
                  obscureText: _obscurePassword,
                  scale: s,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: _textSecondary,
                      size: 20 * s,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16 * s),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/seller/forgot-password');
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w600,
                        color: _orange,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32 * s),

                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  height: 56 * s,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * s),
                      ),
                      disabledBackgroundColor: _primaryBlue.withValues(alpha: 0.6),
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            width: 24 * s,
                            height: 24 * s,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Se connecter',
                            style: GoogleFonts.inter(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 32 * s),

                // Lien vers inscription
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Nouveau vendeur ? ', style: body(16)),
                      TextButton(
                        onPressed: () {
                          context.push('/seller/register');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * s,
                            vertical: 4 * s,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Créer un compte',
                          style: GoogleFonts.inter(
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w600,
                            color: _primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required double scale,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: _primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12 * scale),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 16 * scale,
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(sellerAuthControllerProvider.notifier);
    
    await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}
