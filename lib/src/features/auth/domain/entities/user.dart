import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String userType;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.email,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, userType, createdAt, updatedAt];
}