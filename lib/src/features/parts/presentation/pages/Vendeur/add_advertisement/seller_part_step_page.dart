import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/providers/providers.dart';
import 'seller_shared_widgets.dart';

class SellerPartStepPage extends ConsumerStatefulWidget {
  final String selectedCategory;
  final Function(String partName, bool hasMultiple, double price, String description) onPartSubmitted;

  const SellerPartStepPage({
    super.key,
    required this.selectedCategory,
    required this.onPartSubmitted,
  });

  @override
  ConsumerState<SellerPartStepPage> createState() => _SellerPartStepPageState();
}

class _SellerPartStepPageState extends ConsumerState<SellerPartStepPage> {
  final TextEditingController _partController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _hasMultiple = false;
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
    _partController.removeListener(_onTextChanged);
    _partController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() async {
    final query = _partController.text;
    
    // Toujours déclencher un rebuild pour la validation du bouton
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
      
      // Mapping pour la compatibilité
      if (widget.selectedCategory == 'moteur') {
        categoryFilter = 'moteur';
      } else if (widget.selectedCategory == 'carrosserie') {
        categoryFilter = 'NOT_MOTEUR'; // Valeur spéciale pour gérer côté client
      } else if (widget.selectedCategory == 'lesdeux') {
        categoryFilter = null; // Toutes les catégories
      }

      print('🔍 [DEBUG SellerPartStepPage] Query: "$query"');
      print('🔍 [DEBUG SellerPartStepPage] selectedCategory: "${widget.selectedCategory}"');
      print('🔍 [DEBUG SellerPartStepPage] categoryFilter: "$categoryFilter"');

      // Appeler la fonction sans filtre si on veut exclure moteur
      final actualCategoryFilter = categoryFilter == 'NOT_MOTEUR' ? null : categoryFilter;
      
      final response = await ref.read(supabaseClientProvider).rpc('search_parts', params: {
        'search_query': query,
        'filter_category': actualCategoryFilter,
        'limit_results': categoryFilter == 'NOT_MOTEUR' ? 20 : 8,
      });

      if (response != null && mounted) {
        print('🔍 [DEBUG SellerPartStepPage] Response count: ${(response as List).length}');
        
        // Filtrer côté client si nécessaire
        List<Map<String, dynamic>> filteredData = (response as List).cast<Map<String, dynamic>>();
        
        if (categoryFilter == 'NOT_MOTEUR') {
          // Exclure les pièces moteur
          filteredData = filteredData.where((data) => data['category'] != 'moteur').toList();
        }
        
        final parts = filteredData
            .map((data) {
              final name = data['name'] as String?;
              return name ?? '';
            })
            .where((name) => name.isNotEmpty)
            .toSet() // Éviter les doublons
            .toList();
            
        print('🔍 [DEBUG SellerPartStepPage] Suggestions: $parts');

        setState(() {
          _suggestions = parts;
          _showSuggestions = parts.isNotEmpty;
        });
      }
    } catch (e) {
      print('❌ [DEBUG SellerPartStepPage] Erreur recherche: $e');
      // En cas d'erreur, utiliser des suggestions statiques
      _showStaticSuggestions(query);
    }
  }

  void _showStaticSuggestions(String query) {
    final staticSuggestions = <String>[
      // Pièces moteur
      'Moteur complet', 'Boîte de vitesses', 'Turbo', 'Injecteurs', 'Pompe à eau',
      'Alternateur', 'Démarreur', 'Radiateur', 'Courroie de distribution',
      
      // Pièces carrosserie/intérieur
      'Pare-choc avant', 'Pare-choc arrière', 'Capot', 'Coffre', 'Portière',
      'Phare avant', 'Feu arrière', 'Rétroviseur', 'Jantes', 'Siège',
      'Tableau de bord', 'Volant', 'Levier de vitesse',
    ];

    final filtered = staticSuggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _suggestions = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      setState(() => _showSuggestions = false);
    }
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      if (!_selectedParts.contains(suggestion)) {
        _selectedParts.add(suggestion);
      }
      _partController.clear();
      _showSuggestions = false;
    });
  }

  void _removePart(String part) {
    setState(() {
      _selectedParts.remove(part);
    });
  }

  bool _canContinue() {
    final hasParts = _selectedParts.isNotEmpty || _partController.text.trim().isNotEmpty;
    final hasPrice = _priceController.text.trim().isNotEmpty;
    
    print('🔍 [DEBUG SellerPartStepPage] _canContinue:');
    print('  - hasParts: $hasParts (selectedParts: ${_selectedParts.length}, controller: "${_partController.text}")');
    print('  - hasPrice: $hasPrice (price: "${_priceController.text}")');
    print('  - result: ${hasParts && hasPrice}');
    
    return hasParts && hasPrice;
  }

  String _getPartNames() {
    final allParts = _selectedParts.toList();
    if (_partController.text.trim().isNotEmpty && 
        !allParts.contains(_partController.text.trim())) {
      allParts.add(_partController.text.trim());
    }
    return allParts.join(', ');
  }

  void _onSubmit() {
    final partNames = _getPartNames();
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final description = _descriptionController.text.trim();
    
    widget.onPartSubmitted(partNames, _hasMultiple, price, description);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Décrivez votre pièce',
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quelle(s) pièce(s) vendez-vous ?\nIndiquez le prix et une description.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.35,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nom de la pièce
                  SellerSharedWidgets.buildTextField(
                    controller: _partController,
                    focusNode: _focusNode,
                    label: 'Nom de la pièce',
                    hint: 'Ex: Pare-choc avant, Moteur complet...',
                    icon: Icons.build,
                    onChanged: (value) => _onTextChanged(),
                  ),

                  // Suggestions
                  if (_showSuggestions && _suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6E9EF)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return InkWell(
                            onTap: () => _selectSuggestion(suggestion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: index == _suggestions.length - 1
                                        ? Colors.transparent
                                        : const Color(0xFFE6E9EF),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: AppTheme.darkGray, size: 16),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.darkBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Pièces sélectionnées
                  if (_selectedParts.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedParts.map((part) => Chip(
                        label: Text(part),
                        onDeleted: () => _removePart(part),
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppTheme.primaryBlue),
                        deleteIconColor: AppTheme.primaryBlue,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Prix
                  SellerSharedWidgets.buildTextField(
                    controller: _priceController,
                    label: 'Prix (€)',
                    hint: 'Ex: 150',
                    icon: Icons.euro,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}), // Déclencher rebuild pour validation
                  ),
                  
                  const SizedBox(height: 16),

                  // Description
                  SellerSharedWidgets.buildTextField(
                    controller: _descriptionController,
                    label: 'Description (optionnelle)',
                    hint: 'Décrivez l\'état de la pièce, les détails importants...',
                    icon: Icons.description,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 16),

                  // Checkbox pièces multiples
                  InkWell(
                    onTap: () => setState(() => _hasMultiple = !_hasMultiple),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _hasMultiple,
                          onChanged: (value) => setState(() => _hasMultiple = value ?? false),
                          activeColor: AppTheme.primaryBlue,
                        ),
                        const Expanded(
                          child: Text(
                            'J\'ai plusieurs pièces à vendre',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SellerSharedWidgets.buildPrimaryButton(
            label: 'Suivant',
            enabled: _canContinue(),
            onPressed: _canContinue() ? _onSubmit : null,
          ),
        ],
      ),
    );
  }
}