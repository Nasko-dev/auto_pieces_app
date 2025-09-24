import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/part_advertisement.dart';
import '../../domain/repositories/part_advertisement_repository.dart';
import '../../data/models/part_advertisement_model.dart';
import '../../../../core/providers/part_advertisement_providers.dart';

part 'part_advertisement_controller.freezed.dart';

@freezed
class PartAdvertisementState with _$PartAdvertisementState {
  const factory PartAdvertisementState({
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    String? error,
    PartAdvertisement? currentAdvertisement,
    @Default([]) List<PartAdvertisement> advertisements,
  }) = _PartAdvertisementState;
}

class PartAdvertisementController extends StateNotifier<PartAdvertisementState> {
  final PartAdvertisementRepository _repository;

  PartAdvertisementController(this._repository) : super(const PartAdvertisementState());

  // Créer une nouvelle annonce
  Future<bool> createPartAdvertisement(CreatePartAdvertisementParams params) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final result = await _repository.createPartAdvertisement(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isCreating: false,
            error: failure.message,
          );
          return false;
        },
        (advertisement) {
          state = state.copyWith(
            isCreating: false,
            currentAdvertisement: advertisement,
            error: null,
          );
          // Rafraîchir la liste des annonces si le controller est toujours monté
          if (mounted) getMyAdvertisements();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Erreur inattendue: $e',
      );
      return false;
    }
  }

  // Obtenir une annonce par ID
  Future<void> getAdvertisementById(String id) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.getPartAdvertisementById(id);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: failure.message,
        ),
        (advertisement) => state = state.copyWith(
          isLoading: false,
          currentAdvertisement: advertisement,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue: $e',
      );
    }
  }

  // Obtenir mes annonces
  Future<void> getMyAdvertisements() async {
    try {
      // Vérifier si le controller n'a pas été dispose
      if (!mounted) return;

      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.getMyPartAdvertisements();

      // Vérifier si le controller n'a pas été dispose après l'appel async
      if (!mounted) return;

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (advertisements) {
          state = state.copyWith(
            isLoading: false,
            advertisements: advertisements,
            error: null,
          );
        },
      );
    } catch (e) {
      // Vérifier si le controller n'a pas été dispose
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue: $e',
      );
    }
  }

  // Rechercher des annonces
  Future<List<PartAdvertisement>> searchAdvertisements(SearchPartAdvertisementsParams params) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await _repository.searchPartAdvertisements(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
          return [];
        },
        (advertisements) {
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
          return advertisements;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur inattendue: $e',
      );
      return [];
    }
  }

  // Mettre à jour une annonce
  Future<bool> updateAdvertisement(String id, Map<String, dynamic> updates) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final result = await _repository.updatePartAdvertisement(id, updates);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdating: false,
            error: failure.message,
          );
          return false;
        },
        (advertisement) {
          state = state.copyWith(
            isUpdating: false,
            currentAdvertisement: advertisement,
            error: null,
          );
          // Rafraîchir la liste des annonces si le controller est toujours monté
          if (mounted) getMyAdvertisements();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur inattendue: $e',
      );
      return false;
    }
  }

  // Marquer comme vendu
  Future<bool> markAsSold(String id) async {
    try {
      state = state.copyWith(isUpdating: true, error: null);

      final result = await _repository.markAsSold(id);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isUpdating: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isUpdating: false,
            error: null,
          );
          // Rafraîchir la liste des annonces si le controller est toujours monté
          if (mounted) getMyAdvertisements();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'Erreur inattendue: $e',
      );
      return false;
    }
  }

  // Supprimer une annonce
  Future<bool> deleteAdvertisement(String id) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final result = await _repository.deletePartAdvertisement(id);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isDeleting: false,
            error: failure.message,
          );
          return false;
        },
        (_) {
          state = state.copyWith(
            isDeleting: false,
            error: null,
          );
          // Rafraîchir la liste des annonces si le controller est toujours monté
          if (mounted) getMyAdvertisements();
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        error: 'Erreur inattendue: $e',
      );
      return false;
    }
  }

  // Incrémenter le compteur de vues
  Future<void> incrementViewCount(String id) async {
    // Non-bloquant, on ne gère pas l'état
    await _repository.incrementViewCount(id);
  }

  // Incrémenter le compteur de contacts
  Future<void> incrementContactCount(String id) async {
    // Non-bloquant, on ne gère pas l'état
    await _repository.incrementContactCount(id);
  }

  // Reset de l'état
  void resetState() {
    state = const PartAdvertisementState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider pour le controller
final partAdvertisementControllerProvider = StateNotifierProvider<PartAdvertisementController, PartAdvertisementState>(
  (ref) {
    final repository = ref.watch(partAdvertisementRepositoryProvider);
    return PartAdvertisementController(repository);
  },
);