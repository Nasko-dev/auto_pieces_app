import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/seller_auth_controller.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/haptic_helper.dart';

class SellerRegisterPage extends ConsumerStatefulWidget {
  const SellerRegisterPage({super.key});

  @override
  ConsumerState<SellerRegisterPage> createState() => _SellerRegisterPageState();
}

class _SellerRegisterPageState extends ConsumerState<SellerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _siretController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // Couleurs cohérentes avec le design
  static const _bg = Colors.white;
  static const _primaryBlue = Color(0xFF007AFF);
  static const _textPrimary = Color(0xFF1D1D1F);
  static const _textSecondary = Color(0xFF8E8E93);
  static const _fieldBg = Color(0xFFF2F2F7);
  static const _borderColor = Color(0xFFD1D1D6);

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _siretController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          // Navigation vers l'accueil vendeur après inscription
          if (context.mounted) {
            notificationService.success(
              context,
              'Compte créé avec succès !',
              subtitle: 'Bienvenue ${seller.displayName}',
            );
          }
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
                      Text('Devenir Vendeur', style: h1(32)),
                      SizedBox(height: 8 * s),
                      Text(
                        'Créez votre espace vendeur pour commencer',
                        style: body(16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40 * s),

                // Nom de l'entreprise
                Text('Nom de l\'entreprise *', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _businessNameController,
                  hintText: 'Ex: Auto Pièces Martin',
                  scale: s,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir le nom de votre entreprise';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // Email
                Text('Email professionnel *', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _emailController,
                  hintText: 'votre@entreprise.com',
                  keyboardType: TextInputType.emailAddress,
                  scale: s,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre email professionnel';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Email non valide';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // Téléphone
                Text('Téléphone *', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _phoneController,
                  hintText: '06 12 34 56 78',
                  keyboardType: TextInputType.phone,
                  scale: s,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre numéro de téléphone';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // Adresse
                Text('Adresse de l\'entreprise *', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _addressController,
                  hintText: '123 Rue de la République, 75001 Paris',
                  maxLines: 2,
                  scale: s,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre adresse';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // SIRET
                Text('Numéro SIRET', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _siretController,
                  hintText: '12345678901234 (optionnel)',
                  scale: s,
                ),

                SizedBox(height: 24 * s),

                // Mot de passe
                Text('Mot de passe *', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Minimum 8 caractères',
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
                      return 'Veuillez saisir un mot de passe';
                    }
                    if (value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // Confirmation mot de passe
                Text('Confirmer le mot de passe *', style: h2(16)),
                SizedBox(height: 8 * s),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmez votre mot de passe',
                  obscureText: _obscureConfirmPassword,
                  scale: s,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: _textSecondary,
                      size: 20 * s,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24 * s),

                // Accepter les conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24 * s,
                      height: 24 * s,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: _primaryBlue,
                        checkColor: Colors.white,
                        side: BorderSide(color: _textSecondary),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'J\'accepte les ',
                          style: body(14),
                          children: [
                            TextSpan(
                              text: 'conditions générales',
                              style: GoogleFonts.inter(
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w600,
                                color: _primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  HapticHelper.selection();
                                  // TODO: Créer page CGU
                                  context.push('/privacy');
                                },
                            ),
                            const TextSpan(text: ' et la '),
                            TextSpan(
                              text: 'politique de confidentialité',
                              style: GoogleFonts.inter(
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w600,
                                color: _primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  HapticHelper.selection();
                                  context.push('/privacy');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 32 * s),

                // Bouton d'inscription
                SizedBox(
                  width: double.infinity,
                  height: 56 * s,
                  child: ElevatedButton(
                    onPressed: (authState.isLoading || !_acceptTerms)
                        ? null
                        : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * s),
                      ),
                      disabledBackgroundColor:
                          _primaryBlue.withValues(alpha: 0.6),
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            width: 24 * s,
                            height: 24 * s,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Créer mon compte vendeur',
                            style: GoogleFonts.inter(
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 32 * s),

                // Lien vers connexion
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: body(16),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/seller/login');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8 * s, vertical: 4 * s),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Se connecter',
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
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
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

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = ref.read(sellerAuthControllerProvider.notifier);

    await authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      companyName: _businessNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }
}
