import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_response.dart';
import '../repositories/part_request_repository.dart';

class GetPartRequestResponses implements UseCase<List<SellerResponse>, String> {
  final PartRequestRepository _repository;

  GetPartRequestResponses(this._repository);

  @override
  Future<Either<Failure, List<SellerResponse>>> call(String requestId) async {
    if (requestId.trim().isEmpty) {
      return const Left(ValidationFailure('L\'ID de la demande est requis'));
    }

    return await _repository.getPartRequestResponses(requestId);
  }
}
