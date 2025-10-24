import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';

/// Dropdown avec recherche et scroll, style iOS inspiré du PopupMenu
///
/// Caractéristiques :
/// - Recherche en temps réel (optionnelle)
/// - Scroll automatique pour les longues listes
/// - Hauteur maximale configurable
/// - Style iOS cohérent avec le design de l'app
class SearchableDropdown<T> extends StatefulWidget {
  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.enableSearch = true,
    this.maxHeight = 300,
    this.itemBuilder,
  });

  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final bool enabled;
  final bool enableSearch;
  final double maxHeight;
  final String Function(T)? itemBuilder;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<T> _filteredItems = [];

  static const double _radius = 10;
  static const Color _textGray = AppTheme.gray;
  static const Color _textDark = AppTheme.darkGray;
  static const Color _border = AppColors.grey200;
  static const Color _blue = AppTheme.primaryBlue;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final itemText = widget.itemBuilder != null
              ? widget.itemBuilder!(item)
              : item.toString();
          return itemText.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _showDropdown() {
    if (!widget.enabled) return;

    // Reset search et filtered items
    _searchController.clear();
    _filteredItems = widget.items;

    // Calculer la position du bouton
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => Stack(
        children: [
          // Fond transparent pour fermer au tap
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Le dropdown lui-même
          Positioned(
            left: 24,
            right: 24,
            top: offset.dy + size.height + 4,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                constraints: BoxConstraints(maxHeight: widget.maxHeight),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barre de recherche (si activée)
                    if (widget.enableSearch) ...[
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            hintStyle: TextStyle(
                              color: _textGray.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: _blue,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: 18,
                                      color: _textGray,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.grey100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textDark,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                    // Liste avec scroll
                    Flexible(
                      child: _filteredItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Aucun résultat',
                                style: TextStyle(
                                  color: _textGray.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: _filteredItems.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, color: _border),
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final itemText = widget.itemBuilder != null
                                    ? widget.itemBuilder!(item)
                                    : item.toString();
                                final isSelected = item == widget.value;

                                return ListTile(
                                  dense: true,
                                  selected: isSelected,
                                  selectedTileColor:
                                      _blue.withValues(alpha: 0.1),
                                  title: Text(
                                    itemText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected ? _blue : _textDark,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: _blue,
                                          size: 20,
                                        )
                                      : null,
                                  onTap: () {
                                    widget.onChanged?.call(item);
                                    Navigator.of(context).pop();
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.value != null
        ? (widget.itemBuilder != null
            ? widget.itemBuilder!(widget.value as T)
            : widget.value.toString())
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color:
                widget.enabled ? _textDark : _textGray.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: widget.enabled ? Colors.white : AppColors.grey100,
          borderRadius: BorderRadius.circular(_radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius),
            onTap: widget.enabled ? _showDropdown : null,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(
                  color: widget.enabled
                      ? _border
                      : _textGray.withValues(alpha: 0.3),
                ),
                boxShadow: widget.enabled
                    ? const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      widget.icon,
                      color: widget.enabled
                          ? _blue
                          : _textGray.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      displayText ?? widget.hint,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: displayText != null
                            ? (widget.enabled
                                ? _textDark
                                : _textGray.withValues(alpha: 0.4))
                            : _textGray.withValues(
                                alpha: widget.enabled ? 0.7 : 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: widget.enabled
                          ? _textGray
                          : _textGray.withValues(alpha: 0.4),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
