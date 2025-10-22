import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/part_request.dart';
import '../repositories/part_request_repository.dart';

class CreatePartRequest
    implements UseCase<PartRequest, CreatePartRequestParams> {
  final PartRequestRepository _repository;

  CreatePartRequest(this._repository);

  @override
  Future<Either<Failure, PartRequest>> call(
      CreatePartRequestParams params) async {
    // Validation des paramètres
    if (params.partNames.isEmpty) {
      return const Left(
          ValidationFailure('Au moins une pièce doit être spécifiée'));
    }

    if (params.partType.isEmpty) {
      return const Left(ValidationFailure('Le type de pièce est requis'));
    }

    // Si ce n'est pas anonyme, on doit avoir des informations de véhicule
    if (!params.isAnonymous) {
      final hasPlate = params.vehiclePlate != null;
      final hasCompleteCarInfo = params.vehicleBrand != null &&
          params.vehicleModel != null &&
          params.vehicleYear != null;
      final hasEngineInfo = params.vehicleEngine != null;

      // Pour les pièces moteur, accepter seulement vehicleEngine
      // Pour les pièces carrosserie, exiger les infos complètes ou plaque
      if (params.partType == 'engine') {
        if (!hasPlate && !hasEngineInfo) {
          return const Left(ValidationFailure(
              'La plaque d\'immatriculation ou la motorisation est requise pour les pièces moteur'));
        }
      } else {
        if (!hasPlate && !hasCompleteCarInfo) {
          return const Left(ValidationFailure(
              'La plaque d\'immatriculation ou les informations complètes du véhicule sont requises'));
        }
      }
    }

    return await _repository.createPartRequest(params);
  }
}
