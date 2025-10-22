import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/part_advertisement.dart';
import '../../data/models/part_advertisement_model.dart';

abstract class PartAdvertisementRepository {
  /// Créer une nouvelle annonce de pièce
  Future<Either<Failure, PartAdvertisement>> createPartAdvertisement(
    CreatePartAdvertisementParams params,
  );

  /// Obtenir une annonce par son ID
  Future<Either<Failure, PartAdvertisement>> getPartAdvertisementById(
      String id);

  /// Obtenir toutes les annonces de l'utilisateur connecté
  Future<Either<Failure, List<PartAdvertisement>>> getMyPartAdvertisements();

  /// Rechercher des annonces avec filtres
  Future<Either<Failure, List<PartAdvertisement>>> searchPartAdvertisements(
    SearchPartAdvertisementsParams params,
  );

  /// Mettre à jour une annonce
  Future<Either<Failure, PartAdvertisement>> updatePartAdvertisement(
    String id,
    Map<String, dynamic> updates,
  );

  /// Supprimer une annonce
  Future<Either<Failure, void>> deletePartAdvertisement(String id);

  /// Marquer une annonce comme vendue
  Future<Either<Failure, void>> markAsSold(String id);

  /// Incrémenter le compteur de vues
  Future<Either<Failure, void>> incrementViewCount(String id);

  /// Incrémenter le compteur de contacts
  Future<Either<Failure, void>> incrementContactCount(String id);

  /// Décrémenter le stock après une vente
  Future<Either<Failure, PartAdvertisement>> decrementStock(
      String id, int quantity);

  /// Incrémenter le stock (réappro)
  Future<Either<Failure, PartAdvertisement>> incrementStock(
      String id, int quantity);

  /// Mettre à jour le stock directement
  Future<Either<Failure, PartAdvertisement>> updateStock(
      String id, int newQuantity);
}
