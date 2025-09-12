// Base exception class
abstract class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message);
}

// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

// Authentication-related exceptions
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message);
}