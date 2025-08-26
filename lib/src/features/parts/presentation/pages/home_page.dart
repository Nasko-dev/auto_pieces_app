import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/presentation/widgets/app_menu.dart';
import '../../../../core/constants/car_parts_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Design moderne et cohérent
  static const Color _primary = Color(0xFF007AFF);
  static const Color _primaryLight = Color(0xFFE8F4FD);
  static const Color _success = Color(0xFF34C759);
  static const Color _successLight = Color(0xFFE8F7EA);
  static const Color _textPrimary = Color(0xFF1D1D1F);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _background = Color(0xFFF8F9FA);
  static const Color _cardBackground = Colors.white;
  static const double _radius = 20;

  String _selectedType = 'engine';
  bool _isManualMode = false;
  bool _showDescription = false;

  final _plate = TextEditingController();
  final _partController = TextEditingController();
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _anneeController = TextEditingController();
  final _motorisationController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  List<String> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _partController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _plate.dispose();
    _partController.removeListener(_onTextChanged);
    _partController.dispose();
    _marqueController.dispose();
    _modeleController.dispose();
    _anneeController.dispose();
    _motorisationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 390.0; // Facteur de scale responsive

    return Scaffold(
      backgroundColor: _background,
      body: Column(
        children: [
          // HEADER simple avec indicateur de page
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16 * s,
              bottom: 16 * s,
              left: 16 * s,
              right: 16 * s,
            ),
            color: _background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * s,
                    vertical: 8 * s,
                  ),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(
                      color: _primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Accueil',
                    style: GoogleFonts.inter(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14 * s,
                    ),
                  ),
                ),
                const AppMenu(),
              ],
            ),
          ),

          // CONTENU principal
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre principal
                    Text(
                      'Quel type de pièce recherchez-vous ?',
                      style: GoogleFonts.inter(
                        fontSize: 22 * s,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: _textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Text(
                      'Sélectionnez le type de pièce pour commencer',
                      style: GoogleFonts.inter(
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w500,
                        color: _textSecondary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20 * s),

                    // Cartes de sélection modernes
                    Row(
                      children: [
                        Expanded(
                          child: _ModernTypeCard(
                            selected: _selectedType == 'engine',
                            icon: Icons.precision_manufacturing_outlined,
                            title: 'Pièces moteur',
                            subtitle: 'Moteur, transmission',
                            color: _primary,
                            scale: s,
                            onTap: () => setState(() => _selectedType = 'engine'),
                          ),
                        ),
                        SizedBox(width: 16 * s),
                        Expanded(
                          child: _ModernTypeCard(
                            selected: _selectedType == 'body',
                            icon: Icons.directions_car_outlined,
                            title: 'Carrosserie',
                            subtitle: 'Extérieur, intérieur',
                            color: _primary,
                            scale: s,
                            onTap: () => setState(() => _selectedType = 'body'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16 * s),

                    // Section identification du véhicule
                    if (!_isManualMode) ...[
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8 * s),
                                  decoration: BoxDecoration(
                                    color: _primaryLight,
                                    borderRadius: BorderRadius.circular(12 * s),
                                  ),
                                  child: Icon(
                                    Icons.search,
                                    color: _primary,
                                    size: 20 * s,
                                  ),
                                ),
                                SizedBox(width: 12 * s),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Identification automatique',
                                        style: GoogleFonts.inter(
                                          fontSize: 16 * s,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 1 * s),
                                      Text(
                                        'Entrez votre plaque d\'immatriculation',
                                        style: GoogleFonts.inter(
                                          fontSize: 12 * s,
                                          fontWeight: FontWeight.w500,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14 * s),

                            // Champ de saisie moderne
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _background,
                                      borderRadius: BorderRadius.circular(16 * s),
                                      border: Border.all(
                                        color: _plate.text.isNotEmpty 
                                            ? _primary.withOpacity(0.3) 
                                            : Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: _plate,
                                      textAlign: TextAlign.center,
                                      textCapitalization: TextCapitalization.characters,
                                      style: GoogleFonts.inter(
                                        fontSize: 20 * s,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                        color: _textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'AA-123-BB',
                                        hintStyle: GoogleFonts.inter(
                                          color: _textSecondary,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                          fontSize: 20 * s,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18 * s,
                                          horizontal: 20 * s,
                                        ),
                                      ),
                                      onChanged: (v) => setState(() {}),
                                      onSubmitted: (v) => _validatePlateAndScroll(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12 * s),
                                _AnimatedButton(
                                  isActive: _plate.text.isNotEmpty,
                                  onTap: _plate.text.isNotEmpty ? _validatePlateAndScroll : null,
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: _plate.text.isNotEmpty ? Colors.white : _textSecondary,
                                    size: 24 * s,
                                  ),
                                  scale: s,
                                ),
                              ],
                            ),
                            SizedBox(height: 20 * s),
                            
                            // Option alternative avec design amélioré
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.grey.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20 * s),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16 * s,
                                      vertical: 8 * s,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _background,
                                      borderRadius: BorderRadius.circular(20 * s),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.15),
                                      ),
                                    ),
                                    child: Text(
                                      'ou remplir manuellement',
                                      style: GoogleFonts.inter(
                                        fontSize: 12 * s,
                                        fontWeight: FontWeight.w600,
                                        color: _textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.grey.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20 * s),
                            
                            // Bouton manuel élégant
                            _ModernButton(
                              label: 'Saisie manuelle',
                              icon: Icons.edit_outlined,
                              isOutlined: true,
                              onTap: () {
                                setState(() {
                                  _isManualMode = true;
                                  _showDescription = false;
                                });
                              },
                              scale: s,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Espacement dynamique selon l'état
                    if (!_isManualMode && !_canContinue())
                      SizedBox(height: 24 * s)
                    else if (_isManualMode || _canContinue())
                      SizedBox(height: 12 * s),

                    // Mode manuel moderne
                    if (_isManualMode) ...[
                      ..._buildModernManualFields(s),
                      if (_canContinue()) SizedBox(height: 24 * s),
                    ],

                    // Section de description moderne (affichage automatique)
                    if (_canContinue()) ..._buildModernDescriptionSection(s),

                    // Espace final
                    SizedBox(height: 20 * s + MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nouvelle méthode pour les champs manuels modernes
  List<Widget> _buildModernManualFields(double s) {
    return [
      _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec bouton retour
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isManualMode = false;
                      _showDescription = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8 * s),
                    decoration: BoxDecoration(
                      color: _primaryLight,
                      borderRadius: BorderRadius.circular(12 * s),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: _primary,
                      size: 20 * s,
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saisie manuelle',
                        style: GoogleFonts.inter(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'Renseignez les informations de votre véhicule',
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16 * s),
            
            // Champs en grille moderne
            Row(
              children: [
                Expanded(
                  child: _ModernTextField(
                    controller: _marqueController,
                    label: 'Marque',
                    hint: 'Ex: Renault',
                    icon: Icons.branding_watermark_outlined,
                    scale: s,
                    onChanged: () {
                      setState(() {});
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _autoShowDescriptionIfReady();
                      });
                    },
                  ),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: _ModernTextField(
                    controller: _modeleController,
                    label: 'Modèle',
                    hint: 'Ex: Clio',
                    icon: Icons.model_training_outlined,
                    scale: s,
                    onChanged: () {
                      setState(() {});
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _autoShowDescriptionIfReady();
                      });
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16 * s),
            
            Row(
              children: [
                Expanded(
                  child: _ModernTextField(
                    controller: _anneeController,
                    label: 'Année',
                    hint: 'Ex: 2020',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    scale: s,
                    onChanged: () {
                      setState(() {});
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _autoShowDescriptionIfReady();
                      });
                    },
                  ),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: _ModernTextField(
                    controller: _motorisationController,
                    label: 'Motorisation',
                    hint: 'Ex: 1.6L Essence',
                    icon: Icons.speed_outlined,
                    scale: s,
                    onChanged: () {
                      setState(() {});
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _autoShowDescriptionIfReady();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }


  List<Widget> _buildModernDescriptionSection(double s) {
    if (!_showDescription) return [];
    
    return [
      SizedBox(height: 20 * s),
      
      // Véhicule identifié - Version moderne
      _SectionCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    color: _successLight,
                    borderRadius: BorderRadius.circular(16 * s),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: _success,
                    size: 24 * s,
                  ),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Véhicule identifié',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 18 * s,
                          color: _success,
                        ),
                      ),
                      SizedBox(height: 4 * s),
                      Text(
                        _getVehicleInfo(),
                        style: GoogleFonts.inter(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16 * s,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      
      SizedBox(height: 20 * s),
      
      // Section pièces recherchées
      _SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(16 * s),
                  ),
                  child: Icon(
                    Icons.search,
                    color: _primary,
                    size: 24 * s,
                  ),
                ),
                SizedBox(width: 16 * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pièces recherchées',
                        style: GoogleFonts.inter(
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      SizedBox(height: 2 * s),
                      Text(
                        'Indiquez les pièces dont vous avez besoin',
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16 * s),
            
            // Champ de recherche moderne
            _buildModernPartTextField(s),
            
            // Tags des pièces sélectionnées
            if (_selectedParts.isNotEmpty) ...[
              SizedBox(height: 20 * s),
              _buildModernSelectedPartsTags(s),
            ],
          ],
        ),
      ),
      
      SizedBox(height: 20 * s),
      
      // Bouton poster la demande moderne
      _ModernButton(
        label: 'Poster ma demande',
        icon: Icons.rocket_launch_outlined,
        onTap: _canSubmit() ? _submitRequest : null,
        isEnabled: _canSubmit(),
        scale: s,
      ),
    ];
  }

  bool _canContinue() {
    if (_isManualMode) {
      return _canContinueManual();
    } else {
      return _plate.text.isNotEmpty;
    }
  }

  bool _canContinueManual() {
    return _marqueController.text.isNotEmpty &&
           _modeleController.text.isNotEmpty &&
           _anneeController.text.isNotEmpty &&
           _motorisationController.text.isNotEmpty;
  }

  bool _canSubmit() {
    return _selectedParts.isNotEmpty || _partController.text.isNotEmpty;
  }
  
  void _onTextChanged() {
    final query = _partController.text;
    setState(() {
      _suggestions = CarPartsList.searchParts(query);
      _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
    });
  }

  void _selectSuggestion(String suggestion) {
    if (!_selectedParts.contains(suggestion)) {
      setState(() {
        _selectedParts.add(suggestion);
        _partController.clear();
        _showSuggestions = false;
      });
    }
    _focusNode.requestFocus();
  }

  void _removePart(String part) {
    setState(() {
      _selectedParts.remove(part);
    });
  }

  void _validatePlateAndScroll() {
    if (_plate.text.isNotEmpty) {
      setState(() {
        _showDescription = true;
      });
      
      // Scroll automatique vers la section description
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _autoShowDescriptionIfReady() {
    if (_canContinue() && !_showDescription) {
      setState(() {
        _showDescription = true;
      });
      
      // Scroll automatique vers la section description
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _submitRequest() {
    final allParts = _selectedParts.toList();
    if (_partController.text.isNotEmpty && !allParts.contains(_partController.text)) {
      allParts.add(_partController.text);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demande postée avec succès pour ${_getVehicleInfo()}\nPièces: ${allParts.join(', ')}',
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Reset form
    setState(() {
      _selectedType = 'engine';
      _isManualMode = false;
      _showDescription = false;
      _plate.clear();
      _partController.clear();
      _selectedParts.clear();
      _marqueController.clear();
      _modeleController.clear();
      _anneeController.clear();
      _motorisationController.clear();
    });
  }

  Widget _buildModernPartTextField(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(
              color: _focusNode.hasFocus ? _primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _partController,
            focusNode: _focusNode,
            style: GoogleFonts.inter(
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
              color: _textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: moteur, phare, pare-choc...',
              hintStyle: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
              prefixIcon: Icon(
                Icons.auto_fix_high,
                color: _primary,
                size: 20 * s,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16 * s,
                vertical: 18 * s,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        if (_showSuggestions) _buildModernSuggestionsList(s),
      ],
    );
  }

  Widget _buildModernSuggestionsList(double s) {
    return Container(
      margin: EdgeInsets.only(top: 8 * s),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.all(8 * s),
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => SizedBox(height: 4 * s),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12 * s),
              onTap: () => _selectSuggestion(suggestion),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * s,
                  vertical: 12 * s,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 16 * s,
                      color: _textSecondary,
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernSelectedPartsTags(double s) {
    return Wrap(
      spacing: 12 * s,
      runSpacing: 12 * s,
      children: _selectedParts.map((part) => _buildModernPartTag(part, s)).toList(),
    );
  }

  Widget _buildModernPartTag(String part, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: _primaryLight,
        borderRadius: BorderRadius.circular(25 * s),
        border: Border.all(
          color: _primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            part,
            style: GoogleFonts.inter(
              fontSize: 14 * s,
              color: _primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8 * s),
          GestureDetector(
            onTap: () => _removePart(part),
            child: Container(
              padding: EdgeInsets.all(2 * s),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14 * s,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getVehicleInfo() {
    if (_isManualMode) {
      return '${_marqueController.text} ${_modeleController.text} ${_anneeController.text} - ${_motorisationController.text}';
    } else {
      return 'Plaque: ${_plate.text} - Essence 1.6L 110ch';
    }
  }
}

// =============================================================================
// NOUVEAUX COMPOSANTS MODERNES
// =============================================================================

/// Card wrapper moderne avec ombres et coins arrondis
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _HomePageState._cardBackground,
        borderRadius: BorderRadius.circular(_HomePageState._radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Carte de sélection moderne avec animations et nouveau design
class _ModernTypeCard extends StatelessWidget {
  const _ModernTypeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.scale,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? _HomePageState._primaryLight : _HomePageState._cardBackground,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: selected ? color : Colors.grey.withOpacity(0.2),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected ? [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(20 * scale),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.15) : color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(
                    icon,
                    size: 24 * scale,
                    color: color,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: _HomePageState._textPrimary,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: _HomePageState._textSecondary,
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

/// Bouton moderne avec animations
class _ModernButton extends StatelessWidget {
  const _ModernButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.scale,
    this.isOutlined = false,
    this.isEnabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isOutlined;
  final bool isEnabled;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? _HomePageState._primary : _HomePageState._textSecondary;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 56 * scale,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(16 * scale),
        border: isOutlined ? Border.all(color: color, width: 2) : null,
        boxShadow: !isOutlined && isEnabled ? [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(16 * scale),
          onTap: isEnabled ? onTap : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isOutlined ? color : Colors.white,
                  size: 20 * scale,
                ),
                SizedBox(width: 8 * scale),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: isOutlined ? color : Colors.white,
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

/// Champ de texte moderne
class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.scale,
    required this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final double scale;
  final VoidCallback onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: _HomePageState._textPrimary,
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          decoration: BoxDecoration(
            color: _HomePageState._background,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
              color: _HomePageState._textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w400,
                color: _HomePageState._textSecondary,
              ),
              prefixIcon: Icon(
                icon,
                color: _HomePageState._primary,
                size: 20 * scale,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 16 * scale,
              ),
            ),
            onChanged: (value) => onChanged(),
          ),
        ),
      ],
    );
  }
}

/// Bouton animé pour actions
class _AnimatedButton extends StatelessWidget {
  const _AnimatedButton({
    required this.isActive,
    required this.onTap,
    required this.child,
    required this.scale,
  });

  final bool isActive;
  final VoidCallback? onTap;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56 * scale,
      width: 56 * scale,
      decoration: BoxDecoration(
        color: isActive ? _HomePageState._primary : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: isActive ? [
          BoxShadow(
            color: _HomePageState._primary.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(16 * scale),
          onTap: isActive ? onTap : null,
          child: Center(child: child),
        ),
      ),
    );
  }
}

