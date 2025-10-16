import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_rejection.dart';
import '../repositories/part_request_repository.dart';

class RejectPartRequestParams {
  final String sellerId;
  final String partRequestId;
  final String? reason;

  const RejectPartRequestParams({
    required this.sellerId,
    required this.partRequestId,
    this.reason,
  });
}

class RejectPartRequestUseCase
    implements UseCase<SellerRejection, RejectPartRequestParams> {
  final PartRequestRepository repository;

  const RejectPartRequestUseCase({required this.repository});

  @override
  Future<Either<Failure, SellerRejection>> call(
      RejectPartRequestParams params) async {
    try {
      // Créer l'objet de refus
      final rejection = SellerRejection.create(
        sellerId: params.sellerId,
        partRequestId: params.partRequestId,
        reason: params.reason,
      );

      // Enregistrer le refus en base
      final result = await repository.rejectPartRequest(rejection);

      return result.fold(
        (failure) => Left(failure),
        (savedRejection) => Right(savedRejection),
      );
    } catch (e) {
      return Left(ServerFailure('Erreur lors du refus: ${e.toString()}'));
    }
  }
}
