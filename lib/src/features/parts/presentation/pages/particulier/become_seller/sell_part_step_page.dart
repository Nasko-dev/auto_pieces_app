import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/providers/providers.dart';
import 'shared_widgets.dart';

class SellPartStepPage extends ConsumerStatefulWidget {
  final String selectedCategory;
  final Function(String partName, bool hasMultiple) onPartSubmitted;
  final VoidCallback? onClose;

  const SellPartStepPage({
    super.key,
    required this.selectedCategory,
    required this.onPartSubmitted,
    this.onClose,
  });

  @override
  ConsumerState<SellPartStepPage> createState() => _SellPartStepPageState();
}

class _SellPartStepPageState extends ConsumerState<SellPartStepPage> {
  final TextEditingController _partController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasMultiple = false;
  bool _isCompleteVehicle = false;
  bool _isCompleteMotor =
      false; // Option pour moteur complet (catégorie moteur)
  bool _isCompleteBody =
      false; // Option pour carrosserie intérieure complète (catégorie carrosserie)
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  final List<String> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _partController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _partController.removeListener(_onTextChanged);
    _partController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    final query = _partController.text;

    // Toujours appeler setState pour mettre à jour la validation du bouton
    setState(() {});

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      // Déterminer la catégorie selon le type sélectionné
      String? categoryFilter;

      // Mapping pour la compatibilité avec l'ancien système
      if (widget.selectedCategory == 'engine' ||
          widget.selectedCategory == 'moteur') {
        // Filtrer seulement les pièces moteur
        categoryFilter = 'moteur';
      } else if (widget.selectedCategory == 'body' ||
          widget.selectedCategory == 'carrosserie') {
        // Pour "carrosserie", on veut toutes les catégories SAUF moteur
        categoryFilter = 'NOT_MOTEUR'; // Valeur spéciale pour gérer côté client
      } else if (widget.selectedCategory == 'lesdeux') {
        // Pour "lesdeux", on ne filtre pas - toutes les catégories
        categoryFilter = null;
      }
      // Si autre choix, on ne filtre pas (null)

      // Appeler la fonction sans filtre si on veut exclure moteur
      final actualCategoryFilter =
          categoryFilter == 'NOT_MOTEUR' ? null : categoryFilter;

      final response = await ref.read(supabaseClientProvider).rpc(
        'search_parts',
        params: {
          'search_query': query,
          'filter_category': actualCategoryFilter,
          'limit_results': categoryFilter == 'NOT_MOTEUR'
              ? 20
              : 8, // Plus de résultats pour filtrer ensuite
        },
      );

      if (response != null && mounted) {
        // Filtrer côté client si nécessaire
        List<Map<String, dynamic>> filteredData =
            (response as List).cast<Map<String, dynamic>>();

        if (categoryFilter == 'NOT_MOTEUR') {
          // Excluer les pièces moteur
          filteredData = filteredData
              .where((data) => data['category'] != 'moteur')
              .toList();
        }

        final parts = filteredData
            .map((data) {
              final name = data['name'] as String?;
              return name ?? '';
            })
            .where((name) => name.isNotEmpty)
            .take(8)
            .toList();

        setState(() {
          _suggestions = parts;
          _showSuggestions = parts.isNotEmpty && _focusNode.hasFocus;
        });
      }
    } catch (e) {
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
      _partController.text = suggestion;
      setState(() {
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

  void _onCompleteVehicleChanged(bool? value) {
    setState(() {
      _isCompleteVehicle = value ?? false;
      if (_isCompleteVehicle) {
        // Si on coche véhicule complet, désactiver plusieurs pièces, moteur complet et carrosserie complète
        _hasMultiple = false;
        _isCompleteMotor = false;
        _isCompleteBody = false;
        _selectedParts.clear();
        _partController.text = 'Véhicule complet';
      } else {
        // Si on décoche véhicule complet, vider le champ
        if (_partController.text == 'Véhicule complet') {
          _partController.clear();
        }
      }
    });
  }

  void _onCompleteMotorChanged(bool? value) {
    setState(() {
      _isCompleteMotor = value ?? false;
      if (_isCompleteMotor) {
        // Si on coche moteur complet, désactiver plusieurs pièces, véhicule complet et carrosserie complète
        _hasMultiple = false;
        _isCompleteVehicle = false;
        _isCompleteBody = false;
        _selectedParts.clear();
        _partController.text = 'Moteur complet';
      } else {
        // Si on décoche moteur complet, vider le champ
        if (_partController.text == 'Moteur complet') {
          _partController.clear();
        }
      }
    });
  }

  void _onCompleteBodyChanged(bool? value) {
    setState(() {
      _isCompleteBody = value ?? false;
      if (_isCompleteBody) {
        // Si on coche carrosserie complète, désactiver plusieurs pièces, véhicule complet et moteur complet
        _hasMultiple = false;
        _isCompleteVehicle = false;
        _isCompleteMotor = false;
        _selectedParts.clear();
        _partController.text = 'Carrosserie intérieure complète';
      } else {
        // Si on décoche carrosserie complète, vider le champ
        if (_partController.text == 'Carrosserie intérieure complète') {
          _partController.clear();
        }
      }
    });
  }

  bool _isFormValid() {
    final hasText = _partController.text.trim().isNotEmpty;
    final hasParts = _selectedParts.isNotEmpty;

    if (_isCompleteVehicle || _isCompleteMotor || _isCompleteBody) {
      // Mode véhicule complet, moteur complet ou carrosserie complète : toujours valide
      return true;
    } else if (_hasMultiple) {
      // Mode multiple : valide si au moins une pièce sélectionnée OU du texte dans le champ
      final isValid = hasParts || hasText;
      return isValid;
    } else {
      // Mode simple : valide si du texte dans le champ
      return hasText;
    }
  }

  void _handleSubmit() {
    if (_isCompleteVehicle) {
      // Mode véhicule complet
      widget.onPartSubmitted('Véhicule complet', false);
    } else if (_isCompleteMotor) {
      // Mode moteur complet
      widget.onPartSubmitted('Moteur complet', false);
    } else if (_isCompleteBody) {
      // Mode carrosserie intérieure complète
      widget.onPartSubmitted('Carrosserie intérieure complète', false);
    } else if (_hasMultiple) {
      // En mode multiple, envoyer la liste des parts comme une chaîne séparée par des virgules
      final allParts = _selectedParts.toList();
      if (_partController.text.isNotEmpty &&
          !allParts.contains(_partController.text)) {
        allParts.add(_partController.text);
      }
      final partsString = allParts.join(', ');
      widget.onPartSubmitted(partsString, _hasMultiple);
    } else {
      widget.onPartSubmitted(_partController.text, _hasMultiple);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec badge de catégorie
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getCategoryColor().withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(),
                          size: 16,
                          color: _getCategoryColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getCategoryLabel(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Quelle pièce\nvendez-vous ?',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _getCategoryDescription(),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Champ de recherche de pièce (sauf pour catégorie moteur)
                      if (widget.selectedCategory != 'moteur' &&
                          widget.selectedCategory != 'engine') ...[
                        _buildPartSearchField(),
                        if (_hasMultiple && _selectedParts.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildSelectedPartsTags(),
                        ],
                        const SizedBox(height: 24),
                      ],

                      // Options spécifiques à la catégorie
                      _buildCategoryOptions(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid() ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.gray.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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

  Color _getCategoryColor() {
    if (widget.selectedCategory == 'moteur' ||
        widget.selectedCategory == 'engine') {
      return const Color(0xFF2196F3); // Bleu
    } else if (widget.selectedCategory == 'carrosserie' ||
        widget.selectedCategory == 'body') {
      return const Color(0xFF4CAF50); // Vert
    } else {
      return const Color(0xFFFF9800); // Orange
    }
  }

  IconData _getCategoryIcon() {
    if (widget.selectedCategory == 'moteur' ||
        widget.selectedCategory == 'engine') {
      return Icons.settings;
    } else if (widget.selectedCategory == 'carrosserie' ||
        widget.selectedCategory == 'body') {
      return Icons.directions_car;
    } else {
      return Icons.dashboard_customize;
    }
  }

  String _getCategoryLabel() {
    if (widget.selectedCategory == 'moteur' ||
        widget.selectedCategory == 'engine') {
      return 'Pièces moteur';
    } else if (widget.selectedCategory == 'carrosserie' ||
        widget.selectedCategory == 'body') {
      return 'Carrosserie / Habitacle';
    } else {
      return 'Les deux';
    }
  }

  String _getCategoryDescription() {
    if (widget.selectedCategory == 'moteur' ||
        widget.selectedCategory == 'engine') {
      return 'Moteur, turbo, boîte de vitesses, embrayage, démarreur...';
    } else if (widget.selectedCategory == 'carrosserie' ||
        widget.selectedCategory == 'body') {
      return 'Portière, pare-choc, capot, siège, volant, tableau de bord...';
    } else {
      return 'Vous pouvez vendre des pièces moteur et carrosserie';
    }
  }

  Widget _buildPartSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nom de la pièce',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _partController,
            focusNode: _focusNode,
            enabled:
                !_isCompleteVehicle && !_isCompleteMotor && !_isCompleteBody,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkGray,
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Moteur, Pare-choc avant, Phare...',
              hintStyle: TextStyle(
                color: AppTheme.gray.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: _getCategoryColor(),
                size: 22,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _getCategoryColor(),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.grey200.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
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
          Text(
            'Options',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          _buildMultipleCheckbox(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0B1220),
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
            Divider(height: 1, color: AppColors.grey200),
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
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            part,
            style: const TextStyle(
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
              child: const Icon(
                Icons.close,
                size: 12,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pour catégorie MOTEUR : options de quantité
        if (widget.selectedCategory == 'moteur' ||
            widget.selectedCategory == 'engine') ...[
          _buildOptionCheckbox(
            value: _hasMultiple,
            label: 'J\'ai plus que 5 pièces',
            description:
                'Vous avez plusieurs pièces moteur à vendre (plus de 5)',
            icon: Icons.inventory_outlined,
            onChanged: (value) {
              setState(() {
                _hasMultiple = value ?? false;
                if (!_hasMultiple) {
                  _selectedParts.clear();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCheckbox(
            value: !_hasMultiple && !_isCompleteMotor,
            label: 'J\'ai moins de 5 pièces',
            description:
                'Vous avez quelques pièces moteur à vendre (moins de 5)',
            icon: Icons.settings_outlined,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _hasMultiple = false;
                  _isCompleteMotor = false;
                  _selectedParts.clear();
                }
              });
            },
          ),
        ],

        // Pour catégorie CARROSSERIE : options standards
        if (widget.selectedCategory == 'carrosserie' ||
            widget.selectedCategory == 'body') ...[
          _buildOptionCheckbox(
            value: _hasMultiple,
            label: 'J\'ai plusieurs pièces à vendre',
            description: 'Ajoutez plusieurs pièces en même temps',
            icon: Icons.inventory_2_outlined,
            onChanged: (value) {
              setState(() {
                _hasMultiple = value ?? false;
                if (!_hasMultiple) {
                  _selectedParts.clear();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCheckbox(
            value: _isCompleteBody,
            label: 'Carrosserie complète',
            description:
                'Vous vendez toute la carrosserie ou l\'intérieur complet',
            icon: Icons.car_repair_outlined,
            onChanged: _onCompleteBodyChanged,
          ),
        ],

        // Pour catégorie LES DEUX : véhicule complet
        if (widget.selectedCategory == 'lesdeux') ...[
          _buildOptionCheckbox(
            value: _hasMultiple,
            label: 'J\'ai plusieurs pièces à vendre',
            description: 'Ajoutez plusieurs pièces en même temps',
            icon: Icons.inventory_2_outlined,
            onChanged: (value) {
              setState(() {
                _hasMultiple = value ?? false;
                if (!_hasMultiple) {
                  _selectedParts.clear();
                }
              });
            },
          ),
          const SizedBox(height: 12),
          _buildOptionCheckbox(
            value: _isCompleteVehicle,
            label: 'Véhicule complet',
            description: 'Vous vendez le véhicule en entier pour pièces',
            icon: Icons.directions_car_outlined,
            onChanged: _onCompleteVehicleChanged,
          ),
        ],
      ],
    );
  }

  Widget _buildOptionCheckbox({
    required bool value,
    required String label,
    required String description,
    required IconData icon,
    required Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? _getCategoryColor().withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? _getCategoryColor().withValues(alpha: 0.3)
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
                    ? _getCategoryColor().withValues(alpha: 0.15)
                    : AppTheme.lightGray,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value ? _getCategoryColor() : AppTheme.gray,
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
                      color: value ? _getCategoryColor() : AppTheme.darkGray,
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
                  color: value ? _getCategoryColor() : AppTheme.gray,
                  width: 2,
                ),
                activeColor: _getCategoryColor(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
