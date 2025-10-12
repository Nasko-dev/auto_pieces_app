import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../shared/presentation/widgets/app_header.dart';
import '../../../../../shared/presentation/widgets/license_plate_input.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../core/providers/particulier_auth_providers.dart';
import '../../../../../core/providers/user_settings_providers.dart';
import '../../../../../core/providers/vehicle_catalog_providers.dart';
import '../../../../../core/providers/engine_catalog_providers.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';

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
  // Constantes de style iOS
  static const double _radius = 10; // Standard iOS

  String _selectedType = 'engine';
  bool _isManualMode = false;
  bool _showDescription = false;

  final _plate = TextEditingController();
  final _partController = TextEditingController();

  // Pour le mode manuel avec dropdowns
  String? _selectedMarque;
  String? _selectedModele;
  int? _selectedAnnee;

  // Pour les pièces moteur - mode manuel avec 3 dropdowns en cascade
  String? _selectedCylindree;
  String? _selectedFuelType;
  String? _selectedEngineCode;
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

    // Charger les paramètres utilisateur pour récupérer l'avatar
    _loadUserSettings();

    // Vérifier l'état d'authentification au démarrage et connecter si nécessaire
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted) {
        final authController =
            ref.read(particulierAuthControllerProvider.notifier);
        await authController.checkAuthStatus();

        // Si pas connecté, faire une connexion anonyme
        final currentState = ref.read(particulierAuthControllerProvider);
        currentState.when(
          initial: () async => await authController.signInAnonymously(),
          loading: () {},
          anonymousAuthenticated: (particulier) {
            // Recharger les paramètres après authentification
            _loadUserSettings();
          },
          error: (message) async => await authController.signInAnonymously(),
        );
      }
    });

    // Vérifier les demandes actives de manière asynchrone sans bloquer
    // Délai pour laisser l'UI se charger d'abord
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(vehicleSearchProvider.notifier).checkActiveRequest();
      }
    });
  }

  void _loadUserSettings() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    final getUserSettings = ref.read(getUserSettingsProvider);
    await getUserSettings(currentUser.id);
  }

  @override
  void dispose() {
    _plate.dispose();
    _partController.removeListener(_onTextChanged);
    _partController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    const double hPadding = 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // HEADER AVEC COMPOSANT RÉUTILISABLE
            const AppHeader(),

            // CONTENU
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre qui prend toute la largeur de l'écran
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: hPadding),
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
                  padding: const EdgeInsets.symmetric(horizontal: hPadding),
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
                              title: 'Pièces liées à la motorisation ou à la boîte de vitesse',
                              onTap: () =>
                                  setState(() => _selectedType = 'engine'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TypeCard(
                              selected: _selectedType == 'body',
                              icon: Icons.car_repair,
                              title:
                                  'Pièces liées à la carrosserie ou à l\'habitacle',
                              onTap: () =>
                                  setState(() => _selectedType = 'body'),
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
        // Pièces moteur : 3 dropdowns en cascade (cylindrée, carburant, moteur exact)
        // Dropdown Cylindrée
        Consumer(
          builder: (context, ref, child) {
            final cylindersAsync = ref.watch(engineCylindersProvider);
            return cylindersAsync.when(
              data: (cylinders) => _buildDropdown<String>(
                label: 'Cylindrée',
                hint: 'Sélectionnez une cylindrée',
                icon: Icons.speed,
                value: _selectedCylindree,
                items: cylinders,
                onChanged: (value) {
                  setState(() {
                    _selectedCylindree = value;
                    // Reset carburant et moteur quand cylindrée change
                    _selectedFuelType = null;
                    _selectedEngineCode = null;
                  });
                },
                enabled: true,
              ),
              loading: () => _buildLoadingDropdown(
                label: 'Cylindrée',
                hint: 'Chargement...',
                icon: Icons.speed,
              ),
              error: (error, stackTrace) => _buildDropdown<String>(
                label: 'Cylindrée',
                hint: 'Erreur de chargement',
                icon: Icons.speed,
                value: null,
                items: const [],
                onChanged: null,
                enabled: false,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Dropdown Type de carburant
        Consumer(
          builder: (context, ref, child) {
            final fuelTypesAsync = ref.watch(engineFuelTypesProvider);
            return fuelTypesAsync.when(
              data: (fuelTypes) => _buildDropdown<String>(
                label: 'Type de carburant',
                hint: 'Sélectionnez un type de carburant',
                icon: Icons.local_gas_station,
                value: _selectedFuelType,
                items: fuelTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value;
                    // Reset moteur quand carburant change
                    _selectedEngineCode = null;
                  });
                },
                enabled: _selectedCylindree != null &&
                    _selectedCylindree!.isNotEmpty,
              ),
              loading: () => _buildLoadingDropdown(
                label: 'Type de carburant',
                hint: 'Chargement...',
                icon: Icons.local_gas_station,
              ),
              error: (_, __) => _buildDropdown<String>(
                label: 'Type de carburant',
                hint: 'Erreur de chargement',
                icon: Icons.local_gas_station,
                value: null,
                items: const [],
                onChanged: null,
                enabled: false,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Dropdown Moteur exact
        Consumer(
          builder: (context, ref, child) {
            // Créer une clé composite : "cylindree|fuelType"
            final filterKey = '${_selectedCylindree ?? ''}|${_selectedFuelType ?? ''}';
            final engineModelsAsync = ref.watch(engineModelsProvider(filterKey));
            return engineModelsAsync.when(
              data: (engines) => _buildDropdown<String>(
                label: 'Code moteur',
                hint: 'Sélectionnez un code moteur',
                icon: Icons.engineering,
                value: _selectedEngineCode,
                items: engines,
                onChanged: (value) {
                  setState(() {
                    _selectedEngineCode = value;
                  });
                },
                enabled: _selectedCylindree != null &&
                    _selectedCylindree!.isNotEmpty &&
                    _selectedFuelType != null &&
                    _selectedFuelType!.isNotEmpty,
              ),
              loading: () => _buildLoadingDropdown(
                label: 'Code moteur',
                hint: 'Chargement...',
                icon: Icons.engineering,
              ),
              error: (_, __) => _buildDropdown<String>(
                label: 'Code moteur',
                hint: 'Erreur de chargement',
                icon: Icons.engineering,
                value: null,
                items: const [],
                onChanged: null,
                enabled: false,
              ),
            );
          },
        ),
      ] else ...[
        // Pièces carrosserie/intérieur : marque, modèle, année avec dropdowns
        Row(
          children: [
            // Dropdown Marque
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final brandsAsync = ref.watch(vehicleBrandsProvider);
                  return brandsAsync.when(
                    data: (brands) => _buildDropdown<String>(
                      label: 'Marque',
                      hint: 'Sélectionnez une marque',
                      icon: Icons.directions_car,
                      value: _selectedMarque,
                      items: brands,
                      onChanged: (value) {
                        setState(() {
                          _selectedMarque = value;
                          // Reset modèle et année quand marque change
                          _selectedModele = null;
                          _selectedAnnee = null;
                        });
                      },
                      enabled: true,
                    ),
                    loading: () => _buildLoadingDropdown(
                      label: 'Marque',
                      hint: 'Chargement...',
                      icon: Icons.directions_car,
                    ),
                    error: (_, __) => _buildDropdown<String>(
                      label: 'Marque',
                      hint: 'Erreur de chargement',
                      icon: Icons.directions_car,
                      value: null,
                      items: const [],
                      onChanged: null,
                      enabled: false,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Dropdown Modèle
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final modelsAsync =
                      ref.watch(vehicleModelsProvider(_selectedMarque ?? ''));
                  return modelsAsync.when(
                    data: (models) => _buildDropdown<String>(
                      label: 'Modèle',
                      hint: 'Sélectionnez un modèle',
                      icon: Icons.model_training,
                      value: _selectedModele,
                      items: models,
                      onChanged: (value) {
                        setState(() {
                          _selectedModele = value;
                          // Reset année quand modèle change
                          _selectedAnnee = null;
                        });
                      },
                      enabled: _selectedMarque != null &&
                          _selectedMarque!.isNotEmpty,
                    ),
                    loading: () => _buildLoadingDropdown(
                      label: 'Modèle',
                      hint: 'Chargement...',
                      icon: Icons.model_training,
                    ),
                    error: (_, __) => _buildDropdown<String>(
                      label: 'Modèle',
                      hint: 'Erreur de chargement',
                      icon: Icons.model_training,
                      value: null,
                      items: const [],
                      onChanged: null,
                      enabled: false,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dropdown Année
        Consumer(
          builder: (context, ref, child) {
            // Créer une clé stable : "brand|model"
            final brandModel = '${_selectedMarque ?? ''}|${_selectedModele ?? ''}';
            final yearsAsync = ref.watch(vehicleYearsProvider(brandModel));
            return yearsAsync.when(
              data: (years) => _buildDropdown<int>(
                label: 'Année',
                hint: 'Sélectionnez une année',
                icon: Icons.calendar_today,
                value: _selectedAnnee,
                items: years,
                onChanged: (value) {
                  setState(() {
                    _selectedAnnee = value;
                  });
                },
                enabled: _selectedModele != null && _selectedModele!.isNotEmpty,
              ),
              loading: () => _buildLoadingDropdown(
                label: 'Année',
                hint: 'Chargement...',
                icon: Icons.calendar_today,
              ),
              error: (_, __) => _buildDropdown<int>(
                label: 'Année',
                hint: 'Erreur de chargement',
                icon: Icons.calendar_today,
                value: null,
                items: const [],
                onChanged: null,
                enabled: false,
              ),
            );
          },
        ),
      ],
    ];
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<T> items,
    required void Function(T?)? onChanged,
    required bool enabled,
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
          child: DropdownMenu<T>(
            enabled: enabled,
            enableFilter: true,
            enableSearch: true,
            requestFocusOnTap: true,
            width: MediaQuery.of(context).size.width - 48, // padding horizontal
            initialSelection: value,
            hintText: hint,
            leadingIcon: Icon(
              icon,
              color: enabled ? _blue : _textGray.withValues(alpha: 0.5),
              size: 20,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? _textDark : _textGray.withValues(alpha: 0.5),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: enabled ? Colors.white : _textGray.withValues(alpha: 0.05),
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: BorderSide(color: _textGray.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_radius),
                borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
            ),
            dropdownMenuEntries: items
                .map((item) => DropdownMenuEntry<T>(
                      value: item,
                      label: item.toString(),
                      style: MenuItemButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
            onSelected: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingDropdown({
    required String label,
    required String hint,
    required IconData icon,
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
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(icon, color: _blue, size: 20),
              ),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    color: _textGray.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
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
      // Pièces moteur : cylindrée, carburant et code moteur requis
      return _selectedCylindree != null &&
          _selectedCylindree!.isNotEmpty &&
          _selectedFuelType != null &&
          _selectedFuelType!.isNotEmpty &&
          _selectedEngineCode != null &&
          _selectedEngineCode!.isNotEmpty;
    } else {
      // Pièces carrosserie/intérieur : marque, modèle, année requises
      return _selectedMarque != null &&
          _selectedMarque!.isNotEmpty &&
          _selectedModele != null &&
          _selectedModele!.isNotEmpty &&
          _selectedAnnee != null;
    }
  }

  bool _canSubmit() {
    return _selectedParts.isNotEmpty || _partController.text.isNotEmpty;
  }

  void _onTextChanged() async {
    final query = _partController.text.trim();

    // ✅ CORRECTION: Nettoyage robuste des suggestions quand le champ est vide
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
      }
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
      final response =
          await ref.read(supabaseClientProvider).rpc('search_parts', params: {
        'search_query': query,
        'filter_category': categoryFilter,
        'limit_results': 8,
      });

      // ✅ CORRECTION: Vérifier que le texte n'a pas changé pendant l'appel async
      if (!mounted) return;

      // Re-vérifier que le champ n'est pas vide après l'appel async
      final currentQuery = _partController.text.trim();
      if (currentQuery.isEmpty) {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        return;
      }

      if (response != null) {
        final parts = (response as List)
            .map((data) => data['name'] as String)
            .take(8)
            .toList();

        setState(() {
          _suggestions = parts;
          _showSuggestions = parts.isNotEmpty && _focusNode.hasFocus;
        });
      } else {
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
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
      // ✅ CORRECTION: Cacher les suggestions si le champ est vide, même au focus
      if (_partController.text.trim().isEmpty) {
        _suggestions = [];
        _showSuggestions = false;
      } else {
        _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    if (!_selectedParts.contains(suggestion)) {
      setState(() {
        _selectedParts.add(suggestion);
        _partController.clear();
        // ✅ CORRECTION: Nettoyage explicite des suggestions après sélection
        _suggestions = [];
        _showSuggestions = false;
      });
    }
    // Ne pas redonner le focus automatiquement pour éviter de réafficher les suggestions
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
      // Mode manuel : selon le type de pièce
      if (_selectedType == 'body') {
        // Carrosserie : marque + modèle + année seulement
        vehicleBrand = _selectedMarque;
        vehicleModel = _selectedModele;
        vehicleYear = _selectedAnnee;
      } else if (_selectedType == 'engine') {
        // Moteur : construire motorisation à partir des 3 champs
        final engineParts = <String>[];
        if (_selectedCylindree != null) engineParts.add(_selectedCylindree!);
        if (_selectedFuelType != null) engineParts.add(_selectedFuelType!);
        if (_selectedEngineCode != null) engineParts.add(_selectedEngineCode!);
        vehicleEngine = engineParts.isNotEmpty ? engineParts.join(' - ') : null;
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
          vehicleEngine =
              engineParts.isNotEmpty ? engineParts.join(' - ') : null;
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
      _selectedMarque = null;
      _selectedModele = null;
      _selectedAnnee = null;
      _selectedCylindree = null;
      _selectedFuelType = null;
      _selectedEngineCode = null;
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
                borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
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
            const Divider(height: 1, color: _border),
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
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 1),
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
              child: const Icon(Icons.close, size: 12, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  String _getVehicleInfo() {
    if (_isManualMode) {
      // Mode manuel : afficher les données selon le type de pièce
      if (_selectedType == 'body') {
        // Carrosserie : marque + modèle + année
        final parts = <String>[];
        if (_selectedMarque != null) parts.add(_selectedMarque!);
        if (_selectedModele != null) parts.add(_selectedModele!);
        if (_selectedAnnee != null) parts.add(_selectedAnnee!.toString());
        return parts.isNotEmpty ? parts.join(' - ') : '';
      } else {
        // Moteur : cylindrée + carburant + code moteur
        final parts = <String>[];
        if (_selectedCylindree != null) parts.add(_selectedCylindree!);
        if (_selectedFuelType != null) parts.add(_selectedFuelType!);
        if (_selectedEngineCode != null) parts.add(_selectedEngineCode!);
        return parts.isNotEmpty ? 'Motorisation: ${parts.join(' - ')}' : '';
      }
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
          if (info.make != null)
            _buildInfoRow('Marque', info.make!),
          if (info.model != null)
            _buildInfoRow('Modèle', info.model!),
          if (info.year != null)
            _buildInfoRow('Année', info.year.toString()),
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
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: selected ? AppTheme.primaryBlue : AppColors.grey200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selected
                      ? _blue.withValues(alpha: 0.12)
                      : _blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: selected ? AppTheme.primaryBlue : AppTheme.primaryBlue),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 64,
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
