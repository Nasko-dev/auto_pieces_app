import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/app_menu.dart';
import '../../../../core/constants/car_parts_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Couleurs calibrées pour matcher le screen
  static const Color _blue = Color(0xFF1976D2);
  static const Color _blueDark = Color(0xFF0F57A6);
  static const Color _textDark = Color(0xFF1C1C1E);
  static const Color _textGray = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const double _radius = 16;

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
    final media = MediaQuery.of(context);
    final double hPadding = 24;

    return Scaffold(
      backgroundColor: Colors.white,
      // Pas d'AppBar : on crée un header bleu custom comme sur le screen
      body: Column(
        children: [
          // HEADER BLEU
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: media.padding.top + 14,
              bottom: 18,
            ),
            color: _blue,
            child: Row(
              children: [
                const Spacer(),
                const Text(
                  'Auto Pièces',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    height: 1.1,
                  ),
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: AppMenu(),
                ),
              ],
            ),
          ),

          // CONTENU
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(hPadding, 24, hPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Titre
                  const Text(
                    'Quel type de pièce\nrecherchez-vous ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2 CARTES (sélection)
                  Row(
                    children: [
                      Expanded(
                        child: _TypeCard(
                          selected: _selectedType == 'engine',
                          icon: Icons.settings,
                          title: 'Pièces moteur',
                          onTap: () => setState(() => _selectedType = 'engine'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TypeCard(
                          selected: _selectedType == 'body',
                          icon: Icons.car_repair,
                          title: 'Pièces carrosserie\n/ interieures',
                          onTap: () => setState(() => _selectedType = 'body'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Libellé plaque (par défaut)
                  if (!_isManualMode) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Merci de renseigner votre plaque\nd\'immatriculation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Champ plaque avec bouton OK
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(_radius),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _plate,
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.characters,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                              decoration: InputDecoration(
                                hintText: 'AA-456-BB',
                                hintStyle: TextStyle(
                                  color: _textGray.withOpacity(0.7),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  fontSize: 20,
                                ),
                                prefixIcon: const Icon(Icons.directions_car, color: _blue),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(_radius),
                                  borderSide: const BorderSide(color: _border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(_radius),
                                  borderSide: const BorderSide(color: _border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(_radius),
                                  borderSide: const BorderSide(color: _blue, width: 2),
                                ),
                              ),
                              onChanged: (v) => setState(() {}),
                              onSubmitted: (v) => _validatePlateAndScroll(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            color: _plate.text.isNotEmpty ? _blue : _border,
                            borderRadius: BorderRadius.circular(_radius),
                            boxShadow: _plate.text.isNotEmpty ? const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(_radius),
                              onTap: _plate.text.isNotEmpty ? _validatePlateAndScroll : null,
                              child: Icon(
                                Icons.check,
                                color: _plate.text.isNotEmpty ? Colors.white : _textGray,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Texte "ou remplir manuellement"
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ou remplir les informations manuellement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textGray,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // BOUTON "Manuel"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isManualMode = true;
                          _showDescription = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isManualMode ? _blue : Colors.white,
                        foregroundColor: _isManualMode ? Colors.white : _textDark,
                        elevation: 0,
                        side: !_isManualMode ? const BorderSide(color: _border, width: 1) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_radius),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      child: const Text('Manuel'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Champs manuels - Mode manuel
                  if (_isManualMode) ..._buildManualFields(),

                  // Section description et validation
                  if (_canContinue()) ..._buildDescriptionSection(),

                  // Bouton continuer
                  if (!_showDescription) ...[  
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canContinue() ? _continueToDescription : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radius),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        child: const Text('Continuer'),
                      ),
                    ),
                  ],

                  // Espace bas pour resp. safe area
                  SizedBox(height: media.padding.bottom + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthodes pour la logique de l'application

  List<Widget> _buildManualFields() {
    return [
      // Bouton pour revenir au mode plaque + titre
      Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isManualMode = false;
                _showDescription = false;
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: _blue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Retour plaque d\'immatriculation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      
      // Titre pour les champs manuels
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Informations du véhicule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      const SizedBox(height: 16),
      
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _marqueController,
              label: 'Marque',
              hint: 'Ex: Renault',
              icon: Icons.directions_car,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _modeleController,
              label: 'Modèle',
              hint: 'Ex: Clio',
              icon: Icons.model_training,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _anneeController,
              label: 'Année',
              hint: 'Ex: 2020',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _motorisationController,
              label: 'Motorisation',
              hint: 'Ex: 1.6L Essence',
              icon: Icons.speed,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: _textGray.withOpacity(0.7),
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: _blue, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: _blue, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDescriptionSection() {
    if (!_showDescription) return [];
    
    return [
      const SizedBox(height: 32),
      // Véhicule identifié
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Véhicule identifié',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getVehicleInfo(),
              style: const TextStyle(
                color: _textDark,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 24),
      
      // Titre pièces recherchées
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Quelles pièces recherchez-vous ?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      
      const SizedBox(height: 12),
      
      // Champ de recherche de pièces avec suggestions
      _buildPartTextFieldWithSuggestions(),
      
      // Tags des pièces sélectionnées
      if (_selectedParts.isNotEmpty) ...[
        const SizedBox(height: 16),
        _buildSelectedPartsTags(),
      ],
      
      const SizedBox(height: 24),
      
      // Bouton poster la demande
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _canSubmit() ? _submitRequest : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send, size: 20),
              SizedBox(width: 8),
              Text('Poster ma demande'),
            ],
          ),
        ),
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

  void _continueToDescription() {
    setState(() {
      _showDescription = true;
    });
  }

  void _validatePlateAndScroll() {
    if (_plate.text.isNotEmpty) {
      setState(() {
        _showDescription = true;
      });
      
      // Scroll automatique vers la section description
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
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

  Widget _buildPartTextFieldWithSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _partController,
            focusNode: _focusNode,
            style: const TextStyle(
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Tapez le nom de la pièce (ex: moteur, phare...)',
              hintStyle: TextStyle(
                color: _textGray.withOpacity(0.7),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: _blue, width: 2),
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: _border,
        ),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            title: Text(
              suggestion,
              style: const TextStyle(
                fontSize: 14,
                color: _textDark,
              ),
            ),
            onTap: () => _selectSuggestion(suggestion),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          );
        },
      ),
    );
  }

  Widget _buildSelectedPartsTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedParts.map((part) => _buildPartTag(part)).toList(),
    );
  }

  Widget _buildPartTag(String part) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            part,
            style: TextStyle(
              fontSize: 14,
              color: _blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removePart(part),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: _blue,
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

/// Carte de sélection (moteur / carrosserie) fidèle au screen
class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  static const Color _blue = Color(0xFF1976D2);
  static const Color _bgSelected = Color(0xFFEAF2FF);
  static const Color _border = Color(0xFFE5E7EB);
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _bgSelected : Colors.white,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_radius),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: selected ? _blue : _border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected ? _blue.withOpacity(0.12) : _blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected ? _blue : _blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}