import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/presentation/widgets/seller_menu.dart';
import '../../../../../shared/presentation/widgets/license_plate_input.dart';
import '../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../controllers/part_request_controller.dart';
import '../../../domain/entities/part_request.dart';
import '../../../../../core/services/notification_service.dart';

// Provider pour le client Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class SellerCreateRequestPage extends ConsumerStatefulWidget {
  const SellerCreateRequestPage({super.key});

  @override
  ConsumerState<SellerCreateRequestPage> createState() => _SellerCreateRequestPageState();
}

class _SellerCreateRequestPageState extends ConsumerState<SellerCreateRequestPage> {
  // Couleurs pour le thème vendeur
  static const Color _textDark = AppTheme.darkBlue;
  static const Color _textGray = AppTheme.gray;
  static const Color _border = Color(0xFFE5E7EB);
  static const double _radius = 16;

  String _selectedType = 'engine';
  bool _isManualMode = false;

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
    _partController.addListener(() {
      _updateSuggestions(_partController.text);
    });
  }

  void _updateSuggestions(String input) {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    final allSuggestions = _selectedType == 'engine'
        ? [
            'Moteur complet', 'Turbo', 'Culasse', 'Alternateur', 'Démarreur',
            'Pompe à injection', 'Injecteurs', 'Volant moteur', 'Embrayage',
            'Boîte de vitesses', 'Calculateur', 'Vanne EGR', 'FAP',
            'Catalyseur', 'Ligne d\'échappement'
          ]
        : [
            'Capot', 'Aile avant', 'Pare-chocs', 'Porte', 'Hayon',
            'Rétroviseur', 'Phare', 'Feu arrière', 'Siège', 'Volant',
            'Tableau de bord', 'Airbag', 'Console centrale', 'Tapis'
          ];

    setState(() {
      _suggestions = allSuggestions
          .where((s) => s.toLowerCase().contains(input.toLowerCase()))
          .take(5)
          .toList();
      _showSuggestions = _suggestions.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _plate.dispose();
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
    final vehicleState = ref.watch(vehicleSearchProvider);
    final isSearching = vehicleState.isLoading;
    final requestState = ref.watch(partRequestControllerProvider);
    final isLoading = requestState.isCreating;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Rechercher une pièce',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => context.go('/seller/add'),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryBlue.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: SellerMenu()),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête professionnel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode Professionnel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Votre demande sera identifiée comme professionnelle',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Titre de section
            const Text(
              'Quelle pièce recherchez-vous ?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez une demande pour recevoir des propositions',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.gray,
              ),
            ),

            const SizedBox(height: 24),

            // Type de pièce
            _buildSectionTitle('Type de pièce'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    'Pièces moteur',
                    'engine',
                    Icons.settings,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    'Carrosserie',
                    'body',
                    Icons.directions_car,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recherche véhicule
            _buildSectionTitle('Identification du véhicule'),
            const SizedBox(height: 12),
            _buildSearchModeToggle(),

            const SizedBox(height: 16),

            if (!_isManualMode)
              _buildPlateSearch(vehicleState, isSearching)
            else
              _buildManualSearch(),

            const SizedBox(height: 24),

            // Pièces recherchées
            _buildSectionTitle('Pièces recherchées'),
            const SizedBox(height: 12),
            _buildPartInput(),

            if (_selectedParts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedParts.map((part) => _buildChip(part)).toList(),
              ),
            ],

            const SizedBox(height: 32),

            // Bouton de soumission professionnel
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (!isLoading) ? () {
                  if (_canSubmit()) {
                    _submitRequest();
                  } else {
                  }
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radius),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Publier ma demande professionnelle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.darkBlue,
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : _border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : _textGray,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              'Par plaque',
              !_isManualMode,
              () => setState(() => _isManualMode = false),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              'Manuel',
              _isManualMode,
              () => setState(() => _isManualMode = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppTheme.primaryBlue : _textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildPlateSearch(VehicleSearchState vehicleState, bool isSearching) {
    return Column(
      children: [
        LicensePlateInput(
          initialPlate: _plate.text,
          onPlateValidated: (plate) {
            _plate.text = plate;
            _searchPlate();
          },
          showManualOption: false,
          autoSearch: true,
        ),
        if (vehicleState.error != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehicleState.error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        if (vehicleState.vehicleInfo != null)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Véhicule identifié',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${vehicleState.vehicleInfo!.make ?? ''} ${vehicleState.vehicleInfo!.model ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
                if (vehicleState.vehicleInfo!.year != null)
                  Text(
                    'Année: ${vehicleState.vehicleInfo!.year}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.gray),
                  ),
                if (vehicleState.vehicleInfo!.engineSize != null)
                  Text(
                    'Motorisation: ${vehicleState.vehicleInfo!.engineSize}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.gray),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildManualSearch() {
    return Column(
      children: [
        if (_selectedType == 'body') ...[
          _buildTextField('Marque', _marqueController, 'Ex: Renault'),
          const SizedBox(height: 12),
          _buildTextField('Modèle', _modeleController, 'Ex: Clio'),
          const SizedBox(height: 12),
          _buildTextField('Année', _anneeController, 'Ex: 2020', isNumber: true),
        ] else ...[
          _buildTextField('Motorisation', _motorisationController, 'Ex: 1.5 DCI 110cv'),
        ],
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String placeholder, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 16, color: AppTheme.darkBlue),
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        labelStyle: const TextStyle(color: AppTheme.gray),
        hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppTheme.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildPartInput() {
    return Column(
      children: [
        TextField(
          controller: _partController,
          focusNode: _focusNode,
          style: const TextStyle(fontSize: 16, color: AppTheme.darkBlue),
          decoration: InputDecoration(
            hintText: 'Ex: Turbo, Alternateur...',
            hintStyle: TextStyle(color: _textGray.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppTheme.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.primaryBlue),
              onPressed: _addPart,
            ),
          ),
          onSubmitted: (_) => _addPart(),
        ),
        if (_showSuggestions) ...[
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _suggestions.map((suggestion) {
                return ListTile(
                  dense: true,
                  title: Text(suggestion),
                  onTap: () {
                    _partController.text = suggestion;
                    _addPart();
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _selectedParts.remove(label)),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  void _searchPlate() {
    if (_plate.text.isNotEmpty) {
      ref.read(vehicleSearchProvider.notifier).searchVehicle(_plate.text);
    }
  }

  void _addPart() {
    final part = _partController.text.trim();
    if (part.isNotEmpty && !_selectedParts.contains(part)) {
      setState(() {
        _selectedParts.add(part);
        _partController.clear();
        _showSuggestions = false;
      });
    }
  }

  bool _canSubmit() {
    final hasVehicleInfo = !_isManualMode
        ? ref.read(vehicleSearchProvider).vehicleInfo != null
        : _selectedType == 'body'
            ? _marqueController.text.isNotEmpty &&
                _modeleController.text.isNotEmpty &&
                _anneeController.text.isNotEmpty
            : _motorisationController.text.isNotEmpty;

    final hasParts = _selectedParts.isNotEmpty || _partController.text.isNotEmpty;

    // Debug: loguer les conditions
    print('  - _isManualMode: $_isManualMode');
    print('  - _selectedType: $_selectedType');
    print('  - hasVehicleInfo: $hasVehicleInfo');
    print('  - hasParts: $hasParts');
    print('  - _selectedParts: $_selectedParts');
    print('  - _partController.text: "${_partController.text}"');
    if (_isManualMode && _selectedType == 'body') {
      print('  - _marqueController.text: "${_marqueController.text}"');
      print('  - _modeleController.text: "${_modeleController.text}"');
      print('  - _anneeController.text: "${_anneeController.text}"');
    }
    if (_isManualMode && _selectedType == 'engine') {
      print('  - _motorisationController.text: "${_motorisationController.text}"');
    }
    print('  - Result: ${hasVehicleInfo && hasParts}');

    return hasVehicleInfo && hasParts;
  }

  Future<void> _submitRequest() async {

    final allParts = _selectedParts.toList();
    if (_partController.text.isNotEmpty && !allParts.contains(_partController.text)) {
      allParts.add(_partController.text);
    }


    if (allParts.isEmpty) {
      notificationService.error(
        context,
        'Veuillez spécifier au moins une pièce',
      );
      return;
    }

    // Récupérer les informations du véhicule
    String? vehicleBrand;
    String? vehicleModel;
    int? vehicleYear;
    String? vehicleEngine;
    String? vehiclePlate;

    if (_isManualMode) {
      if (_selectedType == 'body') {
        vehicleBrand = _marqueController.text.isNotEmpty ? _marqueController.text : null;
        vehicleModel = _modeleController.text.isNotEmpty ? _modeleController.text : null;
        final yearText = _anneeController.text.trim();
        if (yearText.isNotEmpty) {
          vehicleYear = int.tryParse(yearText);
        }
      } else {
        vehicleEngine = _motorisationController.text.isNotEmpty ? _motorisationController.text : null;
      }
    } else {
      final vehicleInfo = ref.read(vehicleSearchProvider).vehicleInfo;
      if (vehicleInfo != null) {
        vehiclePlate = _plate.text.isNotEmpty ? _plate.text : null;
        vehicleBrand = vehicleInfo.make;
        vehicleModel = vehicleInfo.model;
        vehicleYear = vehicleInfo.year;
        vehicleEngine = vehicleInfo.engineSize;
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
      isAnonymous: false,
      isSellerRequest: true, // Marquer comme demande vendeur
      additionalInfo: 'Demande professionnelle',
    );


    final success = await ref.read(partRequestControllerProvider.notifier).createPartRequest(params);


    if (success && mounted) {
      notificationService.success(
        context,
        'Demande publiée avec succès',
        subtitle: 'Les vendeurs pourront vous contacter',
      );
      context.go('/seller/home');
    } else {
      if (!success) {
        // Afficher l'erreur du controller si disponible
        final controllerState = ref.read(partRequestControllerProvider);
        final errorMessage = controllerState.error;

        if (errorMessage != null && mounted) {
          notificationService.error(
            context,
            'Erreur lors de la création de la demande',
            subtitle: errorMessage,
          );
        } else if (mounted) {
          notificationService.error(
            context,
            'Erreur lors de la création de la demande',
            subtitle: 'Veuillez réessayer',
          );
        }
      }
    }
  }
}