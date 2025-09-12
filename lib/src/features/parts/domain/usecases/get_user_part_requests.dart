import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/part_request.dart';
import '../repositories/part_request_repository.dart';

class GetUserPartRequests implements UseCase<List<PartRequest>, NoParams> {
  final PartRequestRepository _repository;

  GetUserPartRequests(this._repository);

  @override
  Future<Either<Failure, List<PartRequest>>> call(NoParams params) async {
    return await _repository.getUserPartRequests();
  }
}