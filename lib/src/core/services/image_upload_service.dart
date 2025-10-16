import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/failures.dart';

class ImageUploadService {
  final SupabaseClient _supabaseClient;
  static const String _bucketName = 'avatars';

  ImageUploadService(this._supabaseClient);

  /// Upload une image de profil vers Supabase Storage
  /// Retourne l'URL publique de l'image uploadée
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Lire le fichier en bytes
      final bytes = await imageFile.readAsBytes();
      final fileExtension = _getFileExtension(imageFile.path);

      // Générer un nom de fichier unique
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final filePath = '$userId/$fileName';

      // Upload vers Supabase Storage
      await _supabaseClient.storage.from(_bucketName).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(fileExtension),
              upsert: true, // Remplacer si existe déjà
            ),
          );

      // Obtenir l'URL publique
      final publicUrl =
          _supabaseClient.storage.from(_bucketName).getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerFailure('Erreur d\'upload: ${e.message}');
    } catch (e) {
      throw ServerFailure('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Supprime une image de profil existante
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      if (avatarUrl.isEmpty) return;

      // Extraire le chemin du fichier depuis l'URL
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;

      // Le chemin est après '/storage/v1/object/public/avatars/'
      final avatarIndex = pathSegments.indexOf('avatars');
      if (avatarIndex == -1 || avatarIndex >= pathSegments.length - 1) {
        return;
      }

      final filePath = pathSegments.sublist(avatarIndex + 1).join('/');

      await _supabaseClient.storage.from(_bucketName).remove([filePath]);
    } on StorageException {
      // Ne pas throw d'erreur pour la suppression, continuer silencieusement
    } catch (_) {
      // Ne pas throw d'erreur pour la suppression, continuer silencieusement
    }
  }

  /// Obtient l'extension du fichier depuis le chemin
  String _getFileExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    // Valider les extensions supportées
    const supportedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    if (supportedExtensions.contains(extension)) {
      return extension;
    }
    return 'jpg'; // Par défaut
  }

  /// Obtient le type de contenu MIME selon l'extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
