import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  
  NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    // Pour l'instant, on suppose qu'on a toujours internet
    // Dans une vraie app, on peut utiliser connectivity_plus ou internet_connection_checker
    return true;
  }
}

// Provider pour NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});