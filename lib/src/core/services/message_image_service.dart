import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../errors/failures.dart';

class MessageImageService {
  final SupabaseClient _supabaseClient;
  static const String _bucketName = 'message-images';
  static const Uuid _uuid = Uuid();

  MessageImageService(this._supabaseClient);

  /// Upload une image de message vers Supabase Storage
  /// Retourne l'URL publique de l'image uploadée
  Future<String> uploadMessageImage({
    required String conversationId,
    required File imageFile,
  }) async {
    try {
      print('📸 [MessageImageService] Upload image pour conversation: $conversationId');

      // Vérifier et créer le bucket si nécessaire
      await _ensureBucketExists();

      // Lire le fichier en bytes
      final bytes = await imageFile.readAsBytes();
      final fileExtension = _getFileExtension(imageFile.path);

      // Générer un nom de fichier unique
      final fileName = '${_uuid.v4()}.$fileExtension';
      final filePath = '$conversationId/$fileName';

      print('📁 [MessageImageService] Chemin de sauvegarde: $filePath');

      // Upload vers Supabase Storage
      await _supabaseClient.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(fileExtension),
              upsert: false, // Ne pas remplacer
            ),
          );

      // Obtenir l'URL publique
      final publicUrl = _supabaseClient.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      print('✅ [MessageImageService] Image uploadée avec succès: $publicUrl');
      return publicUrl;

    } on StorageException catch (e) {
      print('❌ [MessageImageService] Erreur Supabase Storage: ${e.message}');
      throw ServerFailure('Erreur d\'upload: ${e.message}');
    } catch (e) {
      print('❌ [MessageImageService] Erreur inattendue: $e');
      throw ServerFailure('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Supprime une image de message
  Future<void> deleteMessageImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      // Extraire le chemin du fichier depuis l'URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Le chemin est après '/storage/v1/object/public/message-images/'
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        print('⚠️ [MessageImageService] URL image invalide: $imageUrl');
        return;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('🗑️ [MessageImageService] Suppression image: $filePath');

      await _supabaseClient.storage
          .from(_bucketName)
          .remove([filePath]);

      print('✅ [MessageImageService] Image supprimée avec succès');

    } on StorageException catch (e) {
      print('❌ [MessageImageService] Erreur suppression: ${e.message}');
      // Ne pas throw d'erreur pour la suppression
    } catch (e) {
      print('❌ [MessageImageService] Erreur inattendue suppression: $e');
      // Ne pas throw d'erreur pour la suppression
    }
  }

  /// Valide si le fichier est une image supportée
  bool isValidImageFile(String filePath) {
    final extension = _getFileExtension(filePath);
    const supportedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    return supportedExtensions.contains(extension);
  }

  /// Obtient l'extension du fichier depuis le chemin
  String _getFileExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    // Valider les extensions supportées
    const supportedExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
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
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Vérifie si le bucket existe
  Future<bool> checkBucketExists() async {
    try {
      await _supabaseClient.storage.from(_bucketName).list();
      return true;
    } catch (e) {
      print('❌ [MessageImageService] Bucket $_bucketName n\'existe pas: $e');
      return false;
    }
  }

  /// S'assure que le bucket existe, le crée si nécessaire
  Future<void> _ensureBucketExists() async {
    try {
      // Tenter une opération sur le bucket pour vérifier son existence
      await _supabaseClient.storage.from(_bucketName).list();
      print('✅ [MessageImageService] Bucket $_bucketName existe déjà');
    } catch (e) {
      print('⚠️ [MessageImageService] Bucket $_bucketName n\'existe pas, création...');

      try {
        // Créer le bucket
        await _supabaseClient.storage.createBucket(_bucketName, const BucketOptions(
          public: true,
          allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
          fileSizeLimit: '5242880', // 5MB en string
        ));
        print('✅ [MessageImageService] Bucket $_bucketName créé avec succès');
      } catch (createError) {
        print('❌ [MessageImageService] Erreur création bucket: $createError');
        // Si la création échoue, on continue quand même
        // Le bucket pourrait exister mais avoir des permissions restrictives
      }
    }
  }
}