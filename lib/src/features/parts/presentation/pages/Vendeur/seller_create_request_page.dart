import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/presentation/widgets/seller_header.dart';
import '../../../../../shared/presentation/widgets/license_plate_input.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../core/utils/haptic_helper.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';

// Provider pour le client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class SellerCreateRequestPage extends ConsumerStatefulWidget {
  const SellerCreateRequestPage({super.key});

  @override
  ConsumerState<SellerCreateRequestPage> createState() =>
      _SellerCreateRequestPageState();
}

class _SellerCreateRequestPageState
    extends ConsumerState<SellerCreateRequestPage> {
  // Constantes de style iOS
  static const double _radius = 10; // Standard iOS

  String _selectedType = 'engine'; // 'engine', 'body', ou 'lesdeux'
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
  bool _hasMultiple = false; // Mode plusieurs pièces (+ de 5)

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
            // HEADER identique à la page particulier mais avec SellerHeader
            SellerHeader(
              title: 'Rechercher une pièce',
              showBackButton: true,
              onBackPressed: () => context.go('/seller/add'),
            ),
            const SizedBox(height: 20),

            // CONTENU identique pixel perfect à la page home particulier
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
                      color: AppTheme.darkGray,
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
                      // 3 CARTES (sélection)
                      Row(
                        children: [
                          Expanded(
                            child: _TypeCard(
                              selected: _selectedType == 'engine',
                              icon: Icons.settings,
                              title: 'Pièces moteur',
                              onTap: () =>
                                  setState(() => _selectedType = 'engine'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeCard(
                              selected: _selectedType == 'body',
                              icon: Icons.car_repair,
                              title: 'Carrosserie / Habitacle',
                              onTap: () =>
                                  setState(() => _selectedType = 'body'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeCard(
                              selected: _selectedType == 'lesdeux',
                              icon: Icons.dashboard_customize,
                              title: 'Les deux',
                              onTap: () =>
                                  setState(() => _selectedType = 'lesdeux'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Widget de recherche de plaque avec API identique
                      if (!_isManualMode) ...[
                        LicensePlateInput(
                          initialPlate: _plate.text,
                          onPlateValidated: (plate) {
                            setState(() {
                              _plate.text = plate;
                              _showDescription = true;
                            });
                            // Scroll automatique vers la section description
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
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

                      // Champs manuels - Mode manuel identique
                      if (_isManualMode) ..._buildManualFields(),

                      // Section description et validation identique
                      if (_canContinue()) ..._buildDescriptionSection(),

                      // Bouton continuer identique
                      if (!_showDescription) ...[
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _canContinue() ? _continueToDescription : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
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

  // TOUTES LES MÉTHODES IDENTIQUES À LA PAGE HOME PARTICULIER

  List<Widget> _buildManualFields() {
    return [
      // Bouton pour revenir au mode plaque + titre
      Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticHelper.light();
              setState(() {
                _isManualMode = false;
                _showDescription = false;
              });
            },
            child: const Row(
              children: [
                Icon(Icons.chevron_left, size: 16, color: AppTheme.primaryBlue),
                SizedBox(width: 4),
                Text(
                  'Retour plaque d\'immatriculation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
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
            color: AppTheme.darkGray,
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Champs selon le type de pièce sélectionné
      if (_selectedType == 'engine') ...[
        // Pièces moteur : marque, modèle, année + motorisation
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _marqueController,
                label: 'Marque',
                hint: 'Ex: Peugeot',
                icon: Icons.directions_car,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _modeleController,
                label: 'Modèle',
                hint: 'Ex: 308',
                icon: Icons.model_training,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _anneeController,
          label: 'Année',
          hint: 'Ex: 2022',
          icon: Icons.calendar_today,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _motorisationController,
          label: 'Motorisation',
          hint: 'Ex: 1.6L Essence 110cv',
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
            color: AppTheme.darkGray,
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
                color: AppTheme.gray.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide:
                    const BorderSide(color: AppTheme.primaryBlue, width: 2),
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
            const SizedBox(height: 16),
            ..._buildVehicleInfoRows(),
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
            color: AppTheme.darkGray,
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Options de catégorie
      _buildCategoryOptions(),

      const SizedBox(height: 20),

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
              child: isLoading
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
    // Pour tous les types : marque, modèle, année requises
    final hasBasicInfo = _marqueController.text.isNotEmpty &&
        _modeleController.text.isNotEmpty &&
        _anneeController.text.isNotEmpty;

    if (_selectedType == 'engine') {
      // Pièces moteur : marque + modèle + année + motorisation requises
      return hasBasicInfo && _motorisationController.text.isNotEmpty;
    } else {
      // Pièces carrosserie/intérieur : marque + modèle + année requises
      return hasBasicInfo;
    }
  }

  bool _canSubmit() {
    if (_hasMultiple) {
      // Mode multiple : valide si au moins une pièce sélectionnée OU du texte dans le champ
      return _selectedParts.isNotEmpty ||
          _partController.text.trim().isNotEmpty;
    } else {
      // Mode simple : valide si du texte dans le champ
      return _partController.text.trim().isNotEmpty;
    }
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
    } else if (_selectedType == 'lesdeux') {
      categoryFilter = null; // Toutes les catégories
    }

    try {
      // Recherche dans la base de données avec catégorie
      final response =
          await ref.read(supabaseClientProvider).rpc('search_parts', params: {
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
    if (_hasMultiple) {
      // Mode multiple : ajouter à la liste des tags
      if (!_selectedParts.contains(suggestion)) {
        setState(() {
          _selectedParts.add(suggestion);
          _partController.clear();
          _showSuggestions = false;
        });
      }
      _focusNode.requestFocus(); // Garder le focus pour continuer la saisie
    } else {
      // Mode simple : remplacer le texte
      setState(() {
        _partController.text = suggestion;
        _showSuggestions = false;
      });
      _focusNode.unfocus();
    }
  }

  void _removePart(String part) {
    setState(() {
      _selectedParts.remove(part);
    });
  }

  void _onHasMultipleChanged(bool? value) {
    setState(() {
      _hasMultiple = value ?? false;
      if (!_hasMultiple) {
        // Si on désactive le mode multiple, vider la liste des pièces sélectionnées
        _selectedParts.clear();
      }
    });
  }

  void _continueToDescription() {
    setState(() {
      _showDescription = true;
    });
  }

  Future<void> _submitRequest() async {
    final allParts = <String>[];

    if (_hasMultiple) {
      // Mode multiple : inclure toutes les pièces sélectionnées + le texte du champ
      allParts.addAll(_selectedParts);
      if (_partController.text.trim().isNotEmpty &&
          !allParts.contains(_partController.text.trim())) {
        allParts.add(_partController.text.trim());
      }
    } else {
      // Mode simple : juste le texte du champ
      if (_partController.text.trim().isNotEmpty) {
        allParts.add(_partController.text.trim());
      }
    }

    if (allParts.isEmpty) {
      notificationService.error(
        context,
        'Veuillez spécifier au moins une pièce',
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
      // Mode manuel : marque + modèle + année toujours requis
      vehicleBrand =
          _marqueController.text.isNotEmpty ? _marqueController.text : null;
      vehicleModel =
          _modeleController.text.isNotEmpty ? _modeleController.text : null;
      vehicleYear = _anneeController.text.isNotEmpty
          ? int.tryParse(_anneeController.text)
          : null;

      // Motorisation en plus pour pièces moteur
      if (_selectedType == 'engine') {
        vehicleEngine = _motorisationController.text.isNotEmpty
            ? _motorisationController.text
            : null;
      }
    } else {
      // Mode automatique : utiliser les données de l'API selon le type de pièce
      vehiclePlate = _plate.text.isNotEmpty ? _plate.text : null;
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;

        // Pour TOUS les types : marque + modèle + année + motorisation
        vehicleBrand = info.make;
        vehicleModel = info.model;
        vehicleYear = info.year;

        final engineParts = <String>[];
        if (info.engineSize != null) engineParts.add(info.engineSize!);
        if (info.fuelType != null) engineParts.add(info.fuelType!);
        if (info.power != null) engineParts.add('${info.power}cv');
        vehicleEngine = engineParts.isNotEmpty ? engineParts.join(' - ') : null;
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
      isAnonymous: false, // Les vendeurs ne sont pas anonymes
    );

    // Envoyer la demande via le controller
    final controller = ref.read(partRequestControllerProvider.notifier);
    final success = await controller.createPartRequest(params);

    if (success && mounted) {
      notificationService.showPartRequestCreated(context);

      // Reset form
      _resetForm();
    } else if (mounted) {
      final state = ref.read(partRequestControllerProvider);
      notificationService.error(
        context,
        state.error ?? 'Erreur lors de l\'envoi de la demande',
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
      _hasMultiple = false;
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
              hintStyle: TextStyle(color: AppTheme.gray.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide:
                    const BorderSide(color: AppTheme.primaryBlue, width: 2),
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
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.grey200),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14, color: AppTheme.darkGray),
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
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            part,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryBlue,
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
                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  size: 12, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  String getVehicleInfo() {
    if (_isManualMode) {
      return '${_marqueController.text} ${_modeleController.text} ${_anneeController.text} - ${_motorisationController.text}';
    } else {
      // Utiliser les données de l'API si disponibles
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        final parts = <String>[];

        // Affichage identique pour TOUS les types : marque + modèle + année + motorisation
        if (info.make != null) parts.add(info.make!);
        if (info.model != null) parts.add(info.model!);
        if (info.year != null) parts.add(info.year.toString());
        if (info.engineSize != null) parts.add(info.engineSize!);
        if (info.fuelType != null) parts.add(info.fuelType!);
        if (info.engineCode != null) parts.add(info.engineCode!);

        if (parts.isNotEmpty) {
          return parts.join(' - ');
        }
      }
      return 'Plaque: ${_plate.text}';
    }
  }

  List<Widget> _buildVehicleInfoRows() {
    if (_isManualMode) {
      // Mode manuel
      return [
        if (_marqueController.text.isNotEmpty)
          _buildInfoRow('Marque', _marqueController.text),
        if (_modeleController.text.isNotEmpty)
          _buildInfoRow('Modèle', _modeleController.text),
        if (_anneeController.text.isNotEmpty)
          _buildInfoRow('Année', _anneeController.text),
        if (_motorisationController.text.isNotEmpty)
          _buildInfoRow('Motorisation', _motorisationController.text),
      ];
    } else {
      // Mode API
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;

        // Construire la motorisation
        final motorisationParts = <String>[];
        if (info.engineSize != null) motorisationParts.add(info.engineSize!);
        if (info.fuelType != null) motorisationParts.add(info.fuelType!);
        if (info.engineCode != null) motorisationParts.add(info.engineCode!);

        return [
          if (info.make != null) _buildInfoRow('Marque', info.make!),
          if (info.model != null) _buildInfoRow('Modèle', info.model!),
          if (info.year != null) _buildInfoRow('Année', info.year.toString()),
          if (motorisationParts.isNotEmpty)
            _buildInfoRow('Motorisation', motorisationParts.join(' - ')),
        ];
      }
    }
    return [];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.darkGray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),

          // Options identiques pour TOUTES les catégories
          _buildOptionCheckbox(
            value: _hasMultiple,
            label: 'J\'ai plus de 5 pièces',
            description: 'Vous recherchez plusieurs pièces (plus de 5)',
            icon: Icons.inventory_outlined,
            onChanged: (value) {
              _onHasMultipleChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCheckbox(
            value: !_hasMultiple,
            label: 'J\'ai moins de 5 pièces',
            description: 'Vous recherchez quelques pièces (moins de 5)',
            icon: Icons.settings_outlined,
            onChanged: (value) {
              if (value == true) {
                _onHasMultipleChanged(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCheckbox({
    required bool value,
    required String label,
    required String description,
    required IconData icon,
    required Function(bool?) onChanged,
  }) {
    Color categoryColor;
    if (_selectedType == 'engine') {
      categoryColor = const Color(0xFF2196F3); // Bleu pour moteur
    } else if (_selectedType == 'body') {
      categoryColor = const Color(0xFF4CAF50); // Vert pour carrosserie
    } else {
      categoryColor = const Color(0xFFFF9800); // Orange pour les deux
    }

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? categoryColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? categoryColor.withValues(alpha: 0.3)
                : AppColors.grey200,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: value
                    ? categoryColor.withValues(alpha: 0.15)
                    : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value ? categoryColor : AppTheme.gray,
              ),
            ),
            const SizedBox(width: 14),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: value ? categoryColor : AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(
                  color: value ? categoryColor : AppTheme.gray,
                  width: 2,
                ),
                activeColor: categoryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de sélection (moteur / carrosserie) identique à la page particulier
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

  static const Color _bgSelected = Color(0xFFEAF2FF);
  static const double _radius = 10;

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
              color: selected ? AppTheme.primaryBlue : AppColors.grey200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryBlue.withValues(alpha: 0.12)
                      : AppTheme.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 24,
                    color:
                        selected ? AppTheme.primaryBlue : AppTheme.primaryBlue),
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
