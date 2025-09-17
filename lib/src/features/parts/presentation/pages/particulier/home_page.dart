import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/presentation/widgets/app_menu.dart';
import '../../../../../shared/presentation/widgets/license_plate_input.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../core/providers/particulier_auth_providers.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_request.dart';

// Provider pour le client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Couleurs calibrées pour matcher le screen
  static const Color _blue = Color(0xFF1976D2);
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
  final List<String> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _partController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    
    // Vérifier les demandes actives de manière asynchrone sans bloquer
    // Délai pour laisser l'UI se charger d'abord
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(vehicleSearchProvider.notifier).checkActiveRequest();
      }
    });
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // HEADER INTÉGRÉ À LA PAGE
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: media.padding.top + 16, bottom: 30),
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Avatar utilisateur
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _blue.withValues(alpha: 0.8),
                            _blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22.5),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Section texte avec données utilisateur
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(particulierAuthControllerProvider);

                          return authState.when(
                            initial: () => _buildUserInfo('Bienvenue', 'Chargement...'),
                            loading: () => _buildUserInfo('Bienvenue', 'Chargement...'),
                            anonymousAuthenticated: (particulier) => _buildUserInfo(
                              'Bienvenue',
                              particulier.displayName,
                            ),
                            error: (message) => _buildUserInfo('Bienvenue', 'Particulier'),
                          );
                        },
                      ),
                    ),

                    // Menu sans background
                    const AppMenu(),
                  ],
                ),
              ),
            ),

            // CONTENU
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre qui prend toute la largeur de l'écran
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: const Text(
                    'Quel type de pièce recherchez-vous ?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: _textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reste du contenu avec padding
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

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

                  // Widget de recherche de plaque avec API
                  if (!_isManualMode) ...[
                    LicensePlateInput(
                      initialPlate: _plate.text,
                      onPlateValidated: (plate) {
                        setState(() {
                          _plate.text = plate;
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
                      },
                      onManualMode: () {
                        setState(() {
                          _isManualMode = true;
                          _showDescription = false;
                        });
                      },
                      showManualOption: true,
                      autoSearch: true,
                    ),
                  ],

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
                        onPressed:
                            _canContinue() ? _continueToDescription : null,
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes pour la logique de l'application

  Widget _buildUserInfo(String greeting, String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            color: _textGray,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayName,
          style: const TextStyle(
            color: _textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    );
  }

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
                Icon(Icons.arrow_back_ios, size: 16, color: _blue),
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

      // Titre pour les champs manuels selon le type
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _selectedType == 'engine' 
            ? 'Informations de motorisation'
            : 'Informations du véhicule',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Champs selon le type de pièce sélectionné
      if (_selectedType == 'engine') ...[
        // Pièces moteur : uniquement motorisation
        _buildTextField(
          controller: _motorisationController,
          label: 'Motorisation',
          hint: 'Ex: 1.6L Essence, 2.0 TDI, 1.4 TSI',
          icon: Icons.speed,
        ),
      ] else ...[
        // Pièces carrosserie/intérieur : marque, modèle, année
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
        _buildTextField(
          controller: _anneeController,
          label: 'Année',
          hint: 'Ex: 2020',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
        ),
      ],
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: _textGray.withValues(alpha: 0.7),
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
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(partRequestControllerProvider);
            final isLoading = state.isCreating;

            return ElevatedButton(
              onPressed: (!isLoading && _canSubmit()) ? _submitRequest : null,
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
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text('Poster ma demande'),
                        ],
                      ),
            );
          },
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
    if (_selectedType == 'engine') {
      // Pièces moteur : seulement motorisation requise
      return _motorisationController.text.isNotEmpty;
    } else {
      // Pièces carrosserie/intérieur : marque, modèle, année requises
      return _marqueController.text.isNotEmpty &&
          _modeleController.text.isNotEmpty &&
          _anneeController.text.isNotEmpty;
    }
  }

  bool _canSubmit() {
    return _selectedParts.isNotEmpty || _partController.text.isNotEmpty;
  }

  void _onTextChanged() async {
    final query = _partController.text;
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Déterminer la catégorie selon le type sélectionné
    String? categoryFilter;
    if (_selectedType == 'engine') {
      categoryFilter = 'moteur';
    } else if (_selectedType == 'body') {
      categoryFilter = 'interieur'; // Pour les pièces carrosserie/intérieur
    }

    try {
      // Recherche dans la base de données avec catégorie
      final response = await ref.read(supabaseClientProvider).rpc('search_parts', params: {
        'search_query': query,
        'filter_category': categoryFilter,
        'limit_results': 8,
      });

      if (response != null && mounted) {
        final parts = (response as List)
            .map((data) => data['name'] as String)
            .take(8)
            .toList();

        setState(() {
          _suggestions = parts;
          _showSuggestions = parts.isNotEmpty && _focusNode.hasFocus;
        });
      }
    } catch (e) {
      // En cas d'erreur, on affiche une liste vide
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
    }
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

  Future<void> _submitRequest() async {

    final allParts = _selectedParts.toList();
    if (_partController.text.isNotEmpty &&
        !allParts.contains(_partController.text)) {
      allParts.add(_partController.text);
    }


    if (allParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez spécifier au moins une pièce'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Créer les paramètres de la demande

    // Récupérer les informations du véhicule selon le mode
    String? vehicleBrand;
    String? vehicleModel;
    int? vehicleYear;
    String? vehicleEngine;
    String? vehiclePlate;

    if (_isManualMode) {
      // Mode manuel : selon le type de pièce
      if (_selectedType == 'body') {
        // Carrosserie : marque + modèle + année seulement
        vehicleBrand = _marqueController.text.isNotEmpty ? _marqueController.text : null;
        vehicleModel = _modeleController.text.isNotEmpty ? _modeleController.text : null;
        vehicleYear = _anneeController.text.isNotEmpty ? int.tryParse(_anneeController.text) : null;
      } else if (_selectedType == 'engine') {
        // Moteur : motorisation seulement
        vehicleEngine = _motorisationController.text.isNotEmpty ? _motorisationController.text : null;
      }
    } else {
      // Mode automatique : utiliser les données de l'API selon le type de pièce
      vehiclePlate = _plate.text.isNotEmpty ? _plate.text : null;
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        
        if (_selectedType == 'body') {
          // Carrosserie : marque + modèle + année depuis l'API
          vehicleBrand = info.make;
          vehicleModel = info.model;
          vehicleYear = info.year;
          
        } else if (_selectedType == 'engine') {
          // Moteur : motorisation seulement depuis l'API
          final engineParts = <String>[];
          if (info.engineSize != null) engineParts.add(info.engineSize!);
          if (info.fuelType != null) engineParts.add(info.fuelType!);
          if (info.power != null) engineParts.add('${info.power}cv');
          vehicleEngine = engineParts.isNotEmpty ? engineParts.join(' - ') : null;
          
        }
      }
    }

    final params = CreatePartRequestParams(
      partType: _selectedType,
      partNames: allParts,
      vehiclePlate: vehiclePlate,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      vehicleEngine: vehicleEngine,
      additionalInfo: null,
      isAnonymous: true, // Pour l'instant, on reste en mode anonyme
    );


    // Envoyer la demande via le controller
    final controller = ref.read(partRequestControllerProvider.notifier);
    final success = await controller.createPartRequest(params);

    if (success && mounted) {
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
      _resetForm();
    } else if (mounted) {
      final state = ref.read(partRequestControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Erreur lors de l\'envoi de la demande'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
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
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Tapez le nom de la pièce (ex: moteur, phare...)',
              hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.7)),
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
        separatorBuilder:
            (context, index) => const Divider(height: 1, color: _border),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14, color: _textDark),
            ),
            onTap: () => _selectSuggestion(suggestion),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
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
        color: _blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _blue.withValues(alpha: 0.3), width: 1),
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
                color: _blue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12, color: _blue),
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
      // Utiliser les données de l'API si disponibles
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        final parts = <String>[];
        
        // Affichage différentiel selon le type de pièce
        if (_selectedType == 'engine') {
          // Pour les pièces moteur : afficher uniquement la motorisation
          if (info.engineSize != null) parts.add(info.engineSize!);
          if (info.fuelType != null) parts.add(info.fuelType!);
          if (info.engineCode != null) parts.add(info.engineCode!);
        } else {
          // Pour les pièces carrosserie/intérieur : afficher marque, modèle, année, version et finition
          if (info.make != null) parts.add(info.make!);
          if (info.model != null) parts.add(info.model!);
          if (info.year != null) parts.add(info.year.toString());
          if (info.bodyStyle != null) parts.add(info.bodyStyle!);
          // Version et finition peuvent être extraites du rawData si disponibles
          final rawData = info.rawData;
          if (rawData != null) {
            final vehicleInfo = rawData['vehicleInformation'] as Map<String, dynamic>?;
            if (vehicleInfo != null) {
              final version = vehicleInfo['version']?.toString();
              final finition = vehicleInfo['trim']?.toString() ?? vehicleInfo['finition']?.toString();
              if (version != null) parts.add(version);
              if (finition != null) parts.add(finition);
            }
          }
        }

        if (parts.isNotEmpty) {
          return parts.join(' - ');
        }
      }
      return 'Plaque: ${_plate.text}';
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
                  color:
                      selected
                          ? _blue.withValues(alpha: 0.12)
                          : _blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: selected ? _blue : _blue),
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
