import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/part_request_repository.dart';
import 'package:dartz/dartz.dart';

class DeletePartRequest implements UseCase<void, String> {
  final PartRequestRepository repository;

  DeletePartRequest(this.repository);

  @override
  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.deletePartRequest(requestId);
  }
}