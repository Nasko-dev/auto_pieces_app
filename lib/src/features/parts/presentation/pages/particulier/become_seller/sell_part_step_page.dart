import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
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
  bool _isCompleteMotor = false; // Nouvelle option pour moteur complet
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
      if (widget.selectedCategory == 'engine' || widget.selectedCategory == 'moteur') {
        // Filtrer seulement les pièces moteur
        categoryFilter = 'moteur';
      } else if (widget.selectedCategory == 'body' || widget.selectedCategory == 'carrosserie') {
        // Pour "carrosserie", on veut toutes les catégories SAUF moteur
        categoryFilter = 'NOT_MOTEUR'; // Valeur spéciale pour gérer côté client
      } else if (widget.selectedCategory == 'lesdeux') {
        // Pour "lesdeux", on ne filtre pas - toutes les catégories
        categoryFilter = null;
      }
      // Si autre choix, on ne filtre pas (null)


      // Appeler la fonction sans filtre si on veut exclure moteur
      final actualCategoryFilter = categoryFilter == 'NOT_MOTEUR' ? null : categoryFilter;

      final response = await ref.read(supabaseClientProvider).rpc('search_parts', params: {
        'search_query': query,
        'filter_category': actualCategoryFilter,
        'limit_results': categoryFilter == 'NOT_MOTEUR' ? 20 : 8, // Plus de résultats pour filtrer ensuite
      });

      if (response != null && mounted) {

        // Filtrer côté client si nécessaire
        List<Map<String, dynamic>> filteredData = (response as List).cast<Map<String, dynamic>>();

        if (categoryFilter == 'NOT_MOTEUR') {
          // Excluer les pièces moteur
          filteredData = filteredData.where((data) => data['category'] != 'moteur').toList();
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

  void _onMultipleChanged(bool? value) {
    setState(() {
      _hasMultiple = value ?? false;
      if (_hasMultiple) {
        // Si on active plusieurs pièces, désactiver véhicule complet et moteur complet
        _isCompleteVehicle = false;
        _isCompleteMotor = false;
      }
      if (!_hasMultiple) {
        // Si on désactive le mode multiple, vider les tags
        _selectedParts.clear();
      } else {
        // Si on active le mode multiple et qu'il y a du texte, l'ajouter aux tags
        if (_partController.text.isNotEmpty && !_selectedParts.contains(_partController.text)) {
          _selectedParts.add(_partController.text);
          _partController.clear();
        }
      }
    });
  }

  void _onCompleteVehicleChanged(bool? value) {
    setState(() {
      _isCompleteVehicle = value ?? false;
      if (_isCompleteVehicle) {
        // Si on coche véhicule complet, désactiver plusieurs pièces et moteur complet
        _hasMultiple = false;
        _isCompleteMotor = false;
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
        // Si on coche moteur complet, désactiver plusieurs pièces et véhicule complet
        _hasMultiple = false;
        _isCompleteVehicle = false;
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

  bool _isFormValid() {
    final hasText = _partController.text.trim().isNotEmpty;
    final hasParts = _selectedParts.isNotEmpty;

    if (_isCompleteVehicle || _isCompleteMotor) {
      // Mode véhicule complet ou moteur complet : toujours valide
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
    } else if (_hasMultiple) {
      // En mode multiple, envoyer la liste des parts comme une chaîne séparée par des virgules
      final allParts = _selectedParts.toList();
      if (_partController.text.isNotEmpty && !allParts.contains(_partController.text)) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Stack(
          children: [
            if (widget.onClose != null)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: widget.onClose,
                ),
              ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A0B1220),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vendre des pièces\nd\'occasion',
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
                        'Merci de noter quelle pièce vous\navez à vendre',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.35,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildPartTextFieldWithSuggestions(),
                      if (_hasMultiple && _selectedParts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildSelectedPartsTags(),
                      ],
                      const SizedBox(height: 16),
                      _buildMultipleCheckbox(),
                      const SizedBox(height: 22),
                      BecomeSellerSharedWidgets.buildPrimaryButton(
                        label: 'Suivant',
                        enabled: _isFormValid(),
                        onPressed: _handleSubmit,
                      ),
                    ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartTextFieldWithSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: TextField(
            controller: _partController,
            focusNode: _focusNode,
            enabled: !_isCompleteVehicle && !_isCompleteMotor,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Tapez le nom de la pièce (ex: moteur, phare...)',
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE6E9EF), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE6E9EF), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
            ),
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
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFE6E9EF),
        ),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            dense: true,
            title: Text(
              suggestion,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray,
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
      children: [
        // Case "Moteur complet"
        Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: _isCompleteMotor,
                onChanged: _onCompleteMotorChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: const BorderSide(color: Color(0xFFD0D5DD), width: 1.2),
                activeColor: AppTheme.primaryBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Moteur complet',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: AppTheme.darkGray,
                ),
              ),
            ),
          ],
        ),
        // N'afficher "Véhicule complet" que si "lesdeux" est sélectionné
        if (widget.selectedCategory == 'lesdeux') ...[
          const SizedBox(height: 12),
          // Case "Véhicule complet"
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _isCompleteVehicle,
                  onChanged: _onCompleteVehicleChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(color: Color(0xFFD0D5DD), width: 1.2),
                  activeColor: AppTheme.primaryBlue,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Véhicule complet',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: AppTheme.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}