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

class CreateSellerResponse
    implements UseCase<SellerResponse, CreateSellerResponseParams> {
  final PartRequestRepository repository;

  CreateSellerResponse(this.repository);

  @override
  Future<Either<Failure, SellerResponse>> call(
      CreateSellerResponseParams params) async {
    // Validation requestId
    if (params.requestId.trim().isEmpty) {
      return const Left(ValidationFailure('L\'ID de la demande est requis'));
    }

    // Validation message
    if (params.message.trim().isEmpty) {
      return const Left(ValidationFailure('Le message est requis'));
    }

    if (params.message.trim().length < 10) {
      return const Left(
          ValidationFailure('Le message doit contenir au moins 10 caractères'));
    }

    // Validation prix
    if (params.price != null && params.price! < 0) {
      return const Left(ValidationFailure('Le prix ne peut pas être négatif'));
    }

    // Validation jours de livraison
    if (params.estimatedDeliveryDays != null &&
        params.estimatedDeliveryDays! < 0) {
      return const Left(ValidationFailure(
          'Les jours de livraison ne peuvent pas être négatifs'));
    }

    // Validation disponibilité
    if (params.availability != null) {
      const validAvailabilities = ['available', 'order_needed', 'unavailable'];
      if (!validAvailabilities.contains(params.availability)) {
        return const Left(ValidationFailure('Disponibilité invalide'));
      }
    }

    // Déléguer au repository
    return await repository.createSellerResponse(params);
  }
}
