import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/part_request.dart';
import '../repositories/part_request_repository.dart';

class GetSellerNotifications implements UseCase<List<PartRequest>, NoParams> {
  final PartRequestRepository repository;

  GetSellerNotifications(this.repository);

  @override
  Future<Either<Failure, List<PartRequest>>> call(NoParams params) async {
    // Cette méthode doit maintenant filtrer les demandes refusées par le vendeur connecté
    return await repository.getActivePartRequestsForSellerWithRejections();
  }
}

class SellerNotification {
  final String id;
  final String vehicleModel;
  final String partType;
  final List<String> partNames;
  final DateTime createdAt;
  final bool isNew;

  const SellerNotification({
    required this.id,
    required this.vehicleModel,
    required this.partType,
    required this.partNames,
    required this.createdAt,
    required this.isNew,
  });

  factory SellerNotification.fromPartRequest(PartRequest request) {
    return SellerNotification(
      id: request.id,
      vehicleModel:
          '${request.vehicleBrand ?? 'Véhicule'} ${request.vehicleModel ?? ''}',
      partType: request.partType,
      partNames: request.partNames,
      createdAt: request.createdAt,
      isNew: DateTime.now().difference(request.createdAt).inHours < 24,
    );
  }
}
