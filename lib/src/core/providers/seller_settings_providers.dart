import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';
import '../../features/parts/domain/entities/seller_settings.dart';

/// Provider pour récupérer les paramètres vendeur
final getSellerSettingsProvider = Provider<GetSellerSettings>((ref) {
  return GetSellerSettings();
});

/// Provider pour sauvegarder les paramètres vendeur
final saveSellerSettingsProvider = Provider<SaveSellerSettings>((ref) {
  return SaveSellerSettings();
});

/// Use case pour récupérer les paramètres vendeur
class GetSellerSettings {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Either<Failure, SellerSettings>> call(String sellerId) async {
    try {
      final response = await _supabase
          .from('sellers')
          .select()
          .eq('id', sellerId)
          .single();

      final settings = SellerSettings(
        sellerId: response['id'],
        companyName: response['company_name'],
        firstName: response['first_name'],
        lastName: response['last_name'],
        email: response['email'],
        phone: response['phone'],
        address: response['address'],
        city: response['city'],
        postalCode: response['postal_code'],
        country: response['country'],
        siret: response['siret'],
        description: response['description'],
        isActive: response['is_active'] ?? true,
        preferences: response['preferences'] != null
            ? Map<String, dynamic>.from(response['preferences'])
            : null,
        createdAt: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : null,
        updatedAt: response['updated_at'] != null
            ? DateTime.parse(response['updated_at'])
            : null,
      );

      return Right(settings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

/// Use case pour sauvegarder les paramètres vendeur
class SaveSellerSettings {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Either<Failure, void>> call(SellerSettings settings) async {
    try {
      await _supabase.from('sellers').update({
        'company_name': settings.companyName,
        'first_name': settings.firstName,
        'last_name': settings.lastName,
        'email': settings.email,
        'phone': settings.phone,
        'address': settings.address,
        'city': settings.city,
        'postal_code': settings.postalCode,
        'country': settings.country,
        'siret': settings.siret,
        'description': settings.description,
        'preferences': settings.preferences,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', settings.sellerId);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}