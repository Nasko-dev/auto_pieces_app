import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/providers/part_request_providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/part_request.dart';
import '../../domain/entities/seller_response.dart';
import '../../domain/usecases/create_part_request.dart';
import '../../domain/usecases/get_user_part_requests.dart';
import '../../domain/usecases/get_part_request_responses.dart';

part 'part_request_controller.freezed.dart';

@freezed
class PartRequestState with _$PartRequestState {
  const factory PartRequestState({
    @Default([]) List<PartRequest> requests,
    @Default([]) List<SellerResponse> responses,
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    @Default(false) bool isLoadingResponses,
    String? error,
    PartRequest? selectedRequest,
  }) = _PartRequestState;
}

class PartRequestController extends StateNotifier<PartRequestState> {
  final CreatePartRequest _createPartRequest;
  final GetUserPartRequests _getUserPartRequests;
  final GetPartRequestResponses _getPartRequestResponses;

  PartRequestController({
    required CreatePartRequest createPartRequest,
    required GetUserPartRequests getUserPartRequests,
    required GetPartRequestResponses getPartRequestResponses,
  })  : _createPartRequest = createPartRequest,
        _getUserPartRequests = getUserPartRequests,
        _getPartRequestResponses = getPartRequestResponses,
        super(const PartRequestState());

  // Créer une nouvelle demande
  Future<bool> createPartRequest(CreatePartRequestParams params) async {
    print('🚀 [PartRequest] Début création de demande');
    print('📋 [PartRequest] Paramètres: ${params.toString()}');
    print('🔧 [PartRequest] Type: ${params.partType}');
    print('🔩 [PartRequest] Pièces: ${params.partNames.join(", ")}');
    print('🚗 [PartRequest] Véhicule: ${params.vehicleBrand} ${params.vehicleModel}');
    print('👤 [PartRequest] Anonyme: ${params.isAnonymous}');
    
    state = state.copyWith(isCreating: true, error: null);

    final result = await _createPartRequest(params);

    return result.fold(
      (failure) {
        print('❌ [PartRequest] Erreur lors de la création');
        print('💥 [PartRequest] Message d\'erreur: ${failure.message}');
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return false;
      },
      (request) {
        print('✅ [PartRequest] Demande créée avec succès');
        print('🆔 [PartRequest] ID: ${request.id}');
        print('📊 [PartRequest] Status: ${request.status}');
        
        // Ajouter la nouvelle demande à la liste
        final updatedRequests = <PartRequest>[request, ...state.requests];
        state = state.copyWith(
          isCreating: false,
          requests: updatedRequests,
          error: null,
        );
        
        print('📝 [PartRequest] Nombre total de demandes: ${updatedRequests.length}');
        return true;
      },
    );
  }

  // Charger les demandes de l'utilisateur
  Future<void> loadUserPartRequests() async {
    print('📥 [PartRequest] Début chargement des demandes utilisateur');
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getUserPartRequests(NoParams());

    result.fold(
      (failure) {
        print('❌ [PartRequest] Erreur lors du chargement');
        print('💥 [PartRequest] Message d\'erreur: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (requests) {
        print('✅ [PartRequest] Demandes chargées avec succès');
        print('📊 [PartRequest] Nombre de demandes: ${requests.length}');
        for (final request in requests) {
          print('🔖 [PartRequest] - ${request.vehicleInfo} | ${request.partNames.join(", ")} | ${request.status}');
        }
        state = state.copyWith(
          isLoading: false,
          requests: requests,
          error: null,
        );
      },
    );
  }

  // Charger les réponses d'une demande spécifique
  Future<void> loadPartRequestResponses(String requestId) async {
    state = state.copyWith(isLoadingResponses: true, error: null);

    final result = await _getPartRequestResponses(requestId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingResponses: false,
          error: failure.message,
        );
      },
      (responses) {
        state = state.copyWith(
          isLoadingResponses: false,
          responses: responses,
          error: null,
        );
      },
    );
  }

  // Sélectionner une demande
  void selectPartRequest(PartRequest? request) {
    state = state.copyWith(selectedRequest: request);
    
    // Charger les réponses si une demande est sélectionnée
    if (request != null) {
      loadPartRequestResponses(request.id);
    } else {
      state = state.copyWith(responses: []);
    }
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    await loadUserPartRequests();
    if (state.selectedRequest != null) {
      await loadPartRequestResponses(state.selectedRequest!.id);
    }
  }

  // Effacer l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Filtrer les demandes
  List<PartRequest> getRequestsByStatus(String status) {
    return state.requests.where((request) => request.status == status).toList();
  }

  // Obtenir les statistiques
  Map<String, int> getStats() {
    final requests = state.requests;
    return {
      'total': requests.length,
      'active': requests.where((r) => r.status == 'active').length,
      'closed': requests.where((r) => r.status == 'closed').length,
      'fulfilled': requests.where((r) => r.status == 'fulfilled').length,
    };
  }
}

// Provider pour le controller
final partRequestControllerProvider = StateNotifierProvider<PartRequestController, PartRequestState>((ref) {
  return PartRequestController(
    createPartRequest: ref.read(createPartRequestProvider),
    getUserPartRequests: ref.read(getUserPartRequestsProvider),
    getPartRequestResponses: ref.read(getPartRequestResponsesProvider),
  );
});