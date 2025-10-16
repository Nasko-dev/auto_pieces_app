import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/providers/immatriculation_providers.dart';
import '../../../../../../core/providers/vehicle_catalog_providers.dart';
import '../../../../../../core/providers/engine_catalog_providers.dart';
import '../../../../../../shared/presentation/widgets/license_plate_input.dart';
import 'shared_widgets.dart';

class PlateStepPage extends ConsumerStatefulWidget {
  final String selectedChoice;
  final String selectedSubType;
  final Function(String plate)? onPlateSubmitted;
  final VoidCallback? onNext;
  final bool isLoading;

  const PlateStepPage({
    super.key,
    required this.selectedChoice,
    required this.selectedSubType,
    this.onPlateSubmitted,
    this.onNext,
    this.isLoading = false,
  }) : assert(onPlateSubmitted != null || onNext != null,
            'Either onPlateSubmitted or onNext must be provided');

  @override
  ConsumerState<PlateStepPage> createState() => _PlateStepPageState();
}

class _PlateStepPageState extends ConsumerState<PlateStepPage> {
  bool _manual = false;
  final TextEditingController _plateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showVehicleInfo = false;

  // Pour les dropdowns véhicule (carrosserie, transmission, body)
  String? _selectedBrand;
  String? _selectedModel;
  int? _selectedYear;

  // Pour les dropdowns moteur
  String? _selectedCylinder;
  String? _selectedFuelType;
  final TextEditingController _horsepowerController = TextEditingController();

  // Pour les dropdowns boîte de vitesses
  String? _selectedTransmissionType;
  String? _selectedGears;
  String? _selectedDriveType;

  @override
  void dispose() {
    _plateController.dispose();
    _horsepowerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getVehicleInfo(WidgetRef ref) {
    if (_manual) {
      // Mode manuel : construire selon le sous-type
      if (widget.selectedSubType == 'engine_parts') {
        // Motorisation
        final parts = <String>[];
        if (_selectedCylinder != null) parts.add(_selectedCylinder!);
        if (_selectedFuelType != null) parts.add(_selectedFuelType!);
        if (_horsepowerController.text.isNotEmpty) {
          parts.add('${_horsepowerController.text}cv');
        }
        return parts.isNotEmpty ? parts.join(' - ') : 'Motorisation manuelle';
      } else if (widget.selectedSubType == 'transmission_parts') {
        // Transmission + véhicule
        final parts = <String>[];
        if (_selectedTransmissionType != null) {
          parts.add(_selectedTransmissionType!);
        }
        if (_selectedGears != null) {
          if (_selectedGears == 'Je ne sais pas') {
            parts.add(_selectedGears!);
          } else {
            parts.add('$_selectedGears vitesses');
          }
        }
        if (_selectedDriveType != null) parts.add(_selectedDriveType!);
        if (_selectedBrand != null) parts.add(_selectedBrand!);
        if (_selectedModel != null) parts.add(_selectedModel!);
        if (_selectedYear != null) parts.add(_selectedYear.toString());
        return parts.isNotEmpty ? parts.join(' - ') : 'Transmission manuelle';
      } else if (widget.selectedSubType == 'body_parts') {
        // Véhicule complet
        final parts = <String>[];
        if (_selectedBrand != null) parts.add(_selectedBrand!);
        if (_selectedModel != null) parts.add(_selectedModel!);
        if (_selectedYear != null) parts.add(_selectedYear.toString());
        return parts.isNotEmpty ? parts.join(' ') : 'Véhicule manuel';
      } else if (widget.selectedSubType == 'both') {
        // Les deux : afficher moteur ET véhicule
        final engineParts = <String>[];
        if (_selectedCylinder != null) engineParts.add(_selectedCylinder!);
        if (_selectedFuelType != null) engineParts.add(_selectedFuelType!);
        if (_horsepowerController.text.isNotEmpty) {
          engineParts.add('${_horsepowerController.text}cv');
        }

        final vehicleParts = <String>[];
        if (_selectedBrand != null) vehicleParts.add(_selectedBrand!);
        if (_selectedModel != null) vehicleParts.add(_selectedModel!);
        if (_selectedYear != null) vehicleParts.add(_selectedYear.toString());

        final allParts = <String>[];
        if (engineParts.isNotEmpty) allParts.add(engineParts.join(' - '));
        if (vehicleParts.isNotEmpty) allParts.add(vehicleParts.join(' '));

        return allParts.isNotEmpty
            ? allParts.join(' • ')
            : 'Information manuelle';
      }
      return 'Information manuelle';
    } else {
      final vehicleState = ref.read(vehicleSearchProvider);
      if (vehicleState.vehicleInfo != null) {
        final info = vehicleState.vehicleInfo!;
        final parts = <String>[];

        if (info.make != null) parts.add(info.make!);
        if (info.model != null) parts.add(info.model!);
        if (info.engineSize != null) parts.add(info.engineSize!);
        if (info.fuelType != null) parts.add(info.fuelType!);
        if (info.engineCode != null) parts.add(info.engineCode!);

        return parts.isNotEmpty
            ? parts.join(' ')
            : 'Informations véhicule disponibles';
      }
      return 'Véhicule non identifié';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Dernière étape avant de\ndéposer votre annonce',
              style: TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBlue,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Merci de renseigner la plaque\nd'immatriculation de votre véhicule afin que\nnous puissions prendre en compte sa\nmotorisation. Si vous n'avez pas la plaque\nd'immatriculation, vous pouvez renseigner\nmanuellement les informations de votre\nvéhicule.",
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                color: AppTheme.darkGray,
              ),
            ),
            const SizedBox(height: 24),
            if (!_manual)
              LicensePlateInput(
                initialPlate: _plateController.text,
                allowWithActiveRequest: true,
                onPlateValidated: (plate) {
                  setState(() {
                    _plateController.text = plate;
                    _showVehicleInfo = true;
                  });
                  // Auto-scroll vers la section véhicule
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                },
                onManualMode: () {
                  setState(() {
                    _manual = true;
                    _showVehicleInfo = false;
                  });
                },
                showManualOption: false,
                autoSearch: true,
              ),

            // MODE MANUEL : Afficher directement les dropdowns selon le sous-type
            if (_manual) ...[
              const SizedBox(height: 12),
              // Afficher les dropdowns selon le sous-type sélectionné
              if (widget.selectedSubType == 'engine_parts') ...[
                ..._buildEngineDropdowns(),
              ] else if (widget.selectedSubType == 'transmission_parts') ...[
                ..._buildTransmissionDropdowns(),
              ] else if (widget.selectedSubType == 'body_parts') ...[
                _buildVehicleDropdowns(),
              ] else if (widget.selectedSubType == 'both') ...[
                // Pour "Les deux" : afficher moteur ET véhicule
                ..._buildEngineDropdowns(),
                const SizedBox(height: 24),
                _buildVehicleDropdowns(),
              ],
            ],

            // Affichage des informations véhicule après validation
            if (_showVehicleInfo && !_manual) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                      _getVehicleInfo(ref),
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Affichage info véhicule en mode manuel après remplissage
            if (_manual && _isManualFormValid()) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
                          'Informations renseignées',
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
                      _getVehicleInfo(ref),
                      style: const TextStyle(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            BecomeSellerSharedWidgets.buildGhostButton(
              label: _manual ? 'Utiliser la plaque' : 'Remplir manuellement',
              onPressed: () => setState(() {
                _manual = !_manual;
                _showVehicleInfo = false;
                // Reset des champs manuels
                _selectedBrand = null;
                _selectedModel = null;
                _selectedYear = null;
                _selectedCylinder = null;
                _selectedFuelType = null;
                _horsepowerController.clear();
                _selectedTransmissionType = null;
                _selectedGears = null;
                _selectedDriveType = null;
              }),
            ),
            const SizedBox(height: 80),
            BecomeSellerSharedWidgets.buildPrimaryButton(
              label: widget.isLoading
                  ? 'Création en cours...'
                  : (widget.onPlateSubmitted != null
                      ? 'Déposer l\'annonce'
                      : 'Suivant'),
              enabled: !widget.isLoading &&
                  (_plateController.text.isNotEmpty ||
                      (_manual && _isManualFormValid()) ||
                      _showVehicleInfo),
              onPressed: widget.isLoading
                  ? null
                  : () {
                      if (widget.onPlateSubmitted != null) {
                        // Construire la valeur à passer selon le mode
                        String plateValue;
                        if (_manual && _isManualFormValid()) {
                          plateValue = _getVehicleInfo(ref);
                        } else {
                          plateValue = _plateController.text;
                        }
                        widget.onPlateSubmitted!(plateValue);
                      } else {
                        widget.onNext!();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEngineDropdowns() {
    return [
      const Text(
        'Informations de motorisation',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.darkGray,
        ),
      ),
      const SizedBox(height: 16),
      // Dropdown Cylindrée
      Consumer(
        builder: (context, ref, child) {
          final cylindersAsync = ref.watch(engineCylindersProvider);
          return cylindersAsync.when(
            data: (cylinders) => _buildDropdown<String>(
              label: 'Cylindrée',
              hint: 'Sélectionnez une cylindrée',
              icon: Icons.speed,
              value: _selectedCylinder,
              items: cylinders,
              onChanged: (value) {
                setState(() {
                  _selectedCylinder = value;
                  _selectedFuelType = null;
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
                });
              },
              enabled:
                  _selectedCylinder != null && _selectedCylinder!.isNotEmpty,
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
      // Champ optionnel pour les chevaux
      _buildTextField(
        label: 'Chevaux (optionnel)',
        hint: 'Ex: 110',
        icon: Icons.flash_on,
        controller: _horsepowerController,
        keyboardType: TextInputType.number,
      ),
    ];
  }

  List<Widget> _buildTransmissionDropdowns() {
    const transmissionTypes = [
      'Manuelle',
      'Automatique',
    ];

    const gearsList = ['4', '5', '6', '7', '8', '9', '10', 'Je ne sais pas'];

    const driveTypes = [
      'Traction',
      'Propulsion',
      '4 roues motrices',
      'Je ne sais pas',
    ];

    return [
      const Text(
        'Informations de la boîte de vitesses',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.darkGray,
        ),
      ),
      const SizedBox(height: 16),
      // Dropdown Type de boîte de vitesse
      _buildDropdown<String>(
        label: 'Type de boîte de vitesse',
        hint: 'Sélectionnez un type',
        icon: Icons.settings_input_composite,
        value: _selectedTransmissionType,
        items: transmissionTypes,
        onChanged: (value) {
          setState(() {
            _selectedTransmissionType = value;
          });
        },
        enabled: true,
      ),
      const SizedBox(height: 16),
      // Dropdown Nombre de rapports
      _buildDropdown<String>(
        label: 'Nombre de rapports',
        hint: 'Sélectionnez le nombre de vitesses',
        icon: Icons.linear_scale,
        value: _selectedGears,
        items: gearsList,
        onChanged: (value) {
          setState(() {
            _selectedGears = value;
          });
        },
        enabled: _selectedTransmissionType != null &&
            _selectedTransmissionType!.isNotEmpty,
      ),
      const SizedBox(height: 16),
      // Dropdown Type de transmission
      _buildDropdown<String>(
        label: 'Type de transmission',
        hint: 'Sélectionnez un type',
        icon: Icons.sync_alt,
        value: _selectedDriveType,
        items: driveTypes,
        onChanged: (value) {
          setState(() {
            _selectedDriveType = value;
          });
        },
        enabled: _selectedGears != null &&
            _selectedGears!.isNotEmpty,
      ),
      const SizedBox(height: 24),
      const Text(
        'Informations du véhicule',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.darkGray,
        ),
      ),
      const SizedBox(height: 16),
      // Dropdowns véhicule
      Consumer(
        builder: (context, ref, child) {
          final brandsAsync = ref.watch(vehicleBrandsProvider);
          return brandsAsync.when(
            data: (brands) => _buildDropdown<String>(
              label: 'Marque',
              hint: 'Sélectionnez une marque',
              icon: Icons.directions_car,
              value: _selectedBrand,
              items: brands,
              onChanged: (value) {
                setState(() {
                  _selectedBrand = value;
                  _selectedModel = null;
                  _selectedYear = null;
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
      const SizedBox(height: 16),
      Consumer(
        builder: (context, ref, child) {
          final modelsAsync =
              ref.watch(vehicleModelsProvider(_selectedBrand ?? ''));
          return modelsAsync.when(
            data: (models) => _buildDropdown<String>(
              label: 'Modèle',
              hint: 'Sélectionnez un modèle',
              icon: Icons.model_training,
              value: _selectedModel,
              items: models,
              onChanged: (value) {
                setState(() {
                  _selectedModel = value;
                  _selectedYear = null;
                });
              },
              enabled: _selectedBrand != null && _selectedBrand!.isNotEmpty,
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
      const SizedBox(height: 16),
      Consumer(
        builder: (context, ref, child) {
          final brandModel = '${_selectedBrand ?? ''}|${_selectedModel ?? ''}';
          final yearsAsync = ref.watch(vehicleYearsProvider(brandModel));
          return yearsAsync.when(
            data: (years) => _buildDropdown<int>(
              label: 'Année',
              hint: 'Sélectionnez une année',
              icon: Icons.calendar_today,
              value: _selectedYear,
              items: years,
              onChanged: (value) {
                setState(() {
                  _selectedYear = value;
                });
              },
              enabled: _selectedModel != null && _selectedModel!.isNotEmpty,
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
    ];
  }

  Widget _buildVehicleDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.selectedChoice != 'carrosserie') ...[
          const Text(
            'Informations du véhicule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Dropdown Marque
        Consumer(
          builder: (context, ref, child) {
            final brandsAsync = ref.watch(vehicleBrandsProvider);
            return brandsAsync.when(
              data: (brands) => _buildDropdown<String>(
                label: 'Marque',
                hint: 'Sélectionnez une marque',
                icon: Icons.directions_car,
                value: _selectedBrand,
                items: brands,
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                    _selectedModel = null;
                    _selectedYear = null;
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
        const SizedBox(height: 16),
        // Dropdown Modèle
        Consumer(
          builder: (context, ref, child) {
            final modelsAsync =
                ref.watch(vehicleModelsProvider(_selectedBrand ?? ''));
            return modelsAsync.when(
              data: (models) => _buildDropdown<String>(
                label: 'Modèle',
                hint: 'Sélectionnez un modèle',
                icon: Icons.model_training,
                value: _selectedModel,
                items: models,
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value;
                    _selectedYear = null;
                  });
                },
                enabled: _selectedBrand != null && _selectedBrand!.isNotEmpty,
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
        const SizedBox(height: 16),
        // Dropdown Année
        Consumer(
          builder: (context, ref, child) {
            final brandModel =
                '${_selectedBrand ?? ''}|${_selectedModel ?? ''}';
            final yearsAsync = ref.watch(vehicleYearsProvider(brandModel));
            return yearsAsync.when(
              data: (years) => _buildDropdown<int>(
                label: 'Année',
                hint: 'Sélectionnez une année',
                icon: Icons.calendar_today,
                value: _selectedYear,
                items: years,
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                  });
                },
                enabled: _selectedModel != null && _selectedModel!.isNotEmpty,
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
    );
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
    const double radius = 10;
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
            borderRadius: BorderRadius.circular(radius),
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
            width: MediaQuery.of(context).size.width - 48,
            initialSelection: value,
            hintText: hint,
            leadingIcon: Icon(
              icon,
              color: enabled
                  ? AppTheme.primaryBlue
                  : AppTheme.gray.withValues(alpha: 0.5),
              size: 20,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? AppTheme.darkGray
                  : AppTheme.gray.withValues(alpha: 0.5),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: enabled
                  ? Colors.white
                  : AppTheme.gray.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide:
                    BorderSide(color: AppTheme.gray.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide:
                    const BorderSide(color: AppTheme.primaryBlue, width: 2),
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
    const double radius = 10;
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
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.grey200),
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
                child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              ),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    color: AppTheme.gray.withValues(alpha: 0.7),
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const double radius = 10;
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
            borderRadius: BorderRadius.circular(radius),
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
              color: AppTheme.darkGray,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppTheme.gray.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide:
                    const BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isManualFormValid() {
    if (widget.selectedSubType == 'engine_parts') {
      // Pour les pièces moteur : cylindrée + carburant requis
      return _selectedCylinder != null &&
          _selectedCylinder!.isNotEmpty &&
          _selectedFuelType != null &&
          _selectedFuelType!.isNotEmpty;
    } else if (widget.selectedSubType == 'transmission_parts') {
      // Pour les pièces boîte/transmission : type boîte + vitesses + drive type + marque + modèle + année requis
      return _selectedTransmissionType != null &&
          _selectedTransmissionType!.isNotEmpty &&
          _selectedGears != null &&
          _selectedGears!.isNotEmpty &&
          _selectedDriveType != null &&
          _selectedDriveType!.isNotEmpty &&
          _selectedBrand != null &&
          _selectedBrand!.isNotEmpty &&
          _selectedModel != null &&
          _selectedModel!.isNotEmpty &&
          _selectedYear != null;
    } else if (widget.selectedSubType == 'body_parts') {
      // Pour la carrosserie : marque + modèle + année requis
      return _selectedBrand != null &&
          _selectedBrand!.isNotEmpty &&
          _selectedModel != null &&
          _selectedModel!.isNotEmpty &&
          _selectedYear != null;
    } else if (widget.selectedSubType == 'both') {
      // Pour "Les deux" : TOUS les champs requis (moteur ET véhicule)
      final engineValid = _selectedCylinder != null &&
          _selectedCylinder!.isNotEmpty &&
          _selectedFuelType != null &&
          _selectedFuelType!.isNotEmpty;

      final vehicleValid = _selectedBrand != null &&
          _selectedBrand!.isNotEmpty &&
          _selectedModel != null &&
          _selectedModel!.isNotEmpty &&
          _selectedYear != null;

      return engineValid && vehicleValid;
    }

    return false;
  }
}
