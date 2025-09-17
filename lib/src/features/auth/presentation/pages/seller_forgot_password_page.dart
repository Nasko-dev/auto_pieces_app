import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/seller_auth_controller.dart';

class SellerForgotPasswordPage extends ConsumerStatefulWidget {
  const SellerForgotPasswordPage({super.key});

  @override
  ConsumerState<SellerForgotPasswordPage> createState() => _SellerForgotPasswordPageState();
}

class _SellerForgotPasswordPageState extends ConsumerState<SellerForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  // Couleurs cohérentes avec le design
  static const _bg = Colors.white;
  static const _primaryBlue = Color(0xFF007AFF);
  static const _textPrimary = Color(0xFF1D1D1F);
  static const _textSecondary = Color(0xFF8E8E93);
  static const _fieldBg = Color(0xFFF2F2F7);
  static const _borderColor = Color(0xFFD1D1D6);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 390.0;
    
    final authState = ref.watch(sellerAuthControllerProvider);
    
    // Écouter les changements d'état pour gérer les réponses
    ref.listen<SellerAuthState>(sellerAuthControllerProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        authenticated: (seller) {},
        unauthenticated: () {
          // Email envoyé avec succès (état unauthenticated signifie succès pour forgot password)
          if (previous?.isLoading == true) {
            setState(() {
              _emailSent = true;
            });
          }
        },
        error: (message) {
          // Affichage de l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
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
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: _textPrimary,
            size: 24 * s,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40 * s),
              
              // Logo et titre
              Center(
                child: Column(
                  children: [
                    Icon(
                      _emailSent ? Icons.email_outlined : Icons.lock_reset_rounded,
                      color: _primaryBlue,
                      size: 80 * s,
                    ),
                    SizedBox(height: 16 * s),
                    Text(
                      _emailSent ? 'Email envoyé !' : 'Mot de passe oublié',
                      style: h1(32),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      _emailSent 
                        ? 'Vérifiez votre boîte mail pour réinitialiser votre mot de passe'
                        : 'Saisissez votre email pour recevoir un lien de réinitialisation',
                      style: body(16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40 * s),
              
              if (!_emailSent) ...[
                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      Text('Email professionnel', style: h2(16)),
                      SizedBox(height: 8 * s),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'votre@entreprise.com',
                        keyboardType: TextInputType.emailAddress,
                        scale: s,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir votre email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Email non valide';
                          }
                          return null;
                        },
                      ),
                      
                      SizedBox(height: 32 * s),
                      
                      // Bouton d'envoi
                      SizedBox(
                        width: double.infinity,
                        height: 56 * s,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleResetPassword,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Envoyer le lien',
                                  style: GoogleFonts.inter(
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // État après envoi
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20 * s),
                      
                      // Instructions
                      Container(
                        padding: EdgeInsets.all(20 * s),
                        decoration: BoxDecoration(
                          color: _fieldBg,
                          borderRadius: BorderRadius.circular(16 * s),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _primaryBlue,
                              size: 24 * s,
                            ),
                            SizedBox(height: 12 * s),
                            Text(
                              'Instructions',
                              style: h2(18),
                            ),
                            SizedBox(height: 8 * s),
                            Text(
                              '1. Vérifiez votre boîte mail (et les spams)\n'
                              '2. Cliquez sur le lien reçu\n'
                              '3. Créez votre nouveau mot de passe\n'
                              '4. Connectez-vous avec vos nouveaux identifiants',
                              style: body(14),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 32 * s),
                      
                      // Bouton retour à la connexion
                      SizedBox(
                        width: double.infinity,
                        height: 56 * s,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/seller/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16 * s),
                            ),
                          ),
                          child: Text(
                            'Retour à la connexion',
                            style: GoogleFonts.inter(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 32 * s),
              
              // Lien pour renvoyer l'email
              if (_emailSent) ...[
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _emailSent = false;
                      });
                    },
                    child: Text(
                      'Email non reçu ? Réessayer',
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w600,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Lien retour à la connexion
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/seller/login');
                    },
                    child: Text(
                      'Retour à la connexion',
                      style: GoogleFonts.inter(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w600,
                        color: _primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 40 * s),
            ],
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

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(sellerAuthControllerProvider.notifier);
    
    await authController.forgotPassword(_emailController.text.trim());
  }
}