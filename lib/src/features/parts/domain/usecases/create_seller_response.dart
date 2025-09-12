import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/seller_response.dart';
import '../repositories/part_request_repository.dart';

class CreateSellerResponseParams {
  final String requestId;
  final String message;
  final double? price;
  final String? availability;
  final int? estimatedDeliveryDays;
  final List<String>? attachments;

  const CreateSellerResponseParams({
    required this.requestId,
    required this.message,
    this.price,
    this.availability,
    this.estimatedDeliveryDays,
    this.attachments,
  });
}

class CreateSellerResponse implements UseCase<SellerResponse, CreateSellerResponseParams> {
  final PartRequestRepository repository;

  CreateSellerResponse(this.repository);

  @override
  Future<Either<Failure, SellerResponse>> call(CreateSellerResponseParams params) async {
    // TODO: Implémenter la création de réponse vendeur
    return const Left(ServerFailure('Not implemented yet'));
  }
}