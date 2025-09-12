import 'dart:async';
import 'package:flutter/material.dart';

/// Liste paginée optimisée pour de gros volumes de données
class PaginatedList<T> {
  final List<T> _items = [];
  final StreamController<List<T>> _controller = StreamController<List<T>>.broadcast();
  
  // Configuration de pagination
  final int pageSize;
  final Future<List<T>> Function(int offset, int limit) _fetchPage;
  
  // État interne
  int _currentOffset = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _lastError;

  PaginatedList({
    required Future<List<T>> Function(int offset, int limit) fetchPage,
    this.pageSize = 20,
  }) : _fetchPage = fetchPage;

  /// Stream des éléments
  Stream<List<T>> get stream => _controller.stream;
  
  /// Éléments actuellement chargés
  List<T> get items => List.unmodifiable(_items);
  
  /// Indique si plus de données sont disponibles
  bool get hasMoreData => _hasMoreData;
  
  /// Indique si un chargement est en cours
  bool get isLoading => _isLoading;
  
  /// Dernière erreur rencontrée
  String? get lastError => _lastError;

  /// Charge la première page
  Future<void> loadInitial() async {
    _items.clear();
    _currentOffset = 0;
    _hasMoreData = true;
    _lastError = null;
    
    await _loadPage();
  }

  /// Charge la page suivante
  Future<void> loadMore() async {
    if (_isLoading || !_hasMoreData) return;
    await _loadPage();
  }

  /// Actualise les données
  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> _loadPage() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _lastError = null;
    
    try {
      final newItems = await _fetchPage(_currentOffset, pageSize);
      
      if (newItems.isEmpty) {
        _hasMoreData = false;
      } else {
        _items.addAll(newItems);
        _currentOffset += newItems.length;
        
        // Si moins d'éléments que demandé, probablement fin de données
        if (newItems.length < pageSize) {
          _hasMoreData = false;
        }
      }
      
      _controller.add(_items);
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  void dispose() {
    _controller.close();
  }
}

/// Widget pour afficher une liste paginée avec loading automatique
class PaginatedListView<T> extends StatefulWidget {
  final PaginatedList<T> paginatedList;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final double loadMoreThreshold;

  const PaginatedListView({
    super.key,
    required this.paginatedList,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.loadMoreThreshold = 200.0,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    
    _scrollController.addListener(_onScroll);
    
    // Écouter les changements de la liste
    _subscription = widget.paginatedList.stream.listen((_) {
      if (mounted) setState(() {});
    });
    
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.paginatedList.loadInitial();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      widget.paginatedList.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.paginatedList.items;
    
    if (items.isEmpty && widget.paginatedList.isLoading) {
      return widget.loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (items.isEmpty && widget.paginatedList.lastError != null) {
      return widget.errorWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: ${widget.paginatedList.lastError}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.paginatedList.refresh(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    if (items.isEmpty) {
      return widget.emptyWidget ?? const Center(
        child: Text('Aucun élément'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.paginatedList.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (widget.paginatedList.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            // Loading indicator à la fin
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          return widget.itemBuilder(context, items[index], index);
        },
      ),
    );
  }
}