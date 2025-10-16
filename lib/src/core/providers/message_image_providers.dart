import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/message_image_service.dart';

// Provider pour le service d'upload d'images de messages
final messageImageServiceProvider = Provider<MessageImageService>((ref) {
  return MessageImageService(Supabase.instance.client);
});
