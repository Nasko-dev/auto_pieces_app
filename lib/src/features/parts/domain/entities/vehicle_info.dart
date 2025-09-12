import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_info.freezed.dart';
part 'vehicle_info.g.dart';

@freezed
class VehicleInfo with _$VehicleInfo {
  const factory VehicleInfo({
    required String registrationNumber,
    String? make,
    String? model,
    String? fuelType,
    String? bodyStyle,
    String? engineSize,
    int? year,
    String? color,
    String? vin,
    String? engineNumber,
    String? engineCode,
    int? co2Emissions,
    String? transmission,
    int? numberOfDoors,
    String? euroStatus,
    String? cylinderCapacity,
    int? power,
    String? powerUnit,
    String? description,
    Map<String, dynamic>? rawData,
  }) = _VehicleInfo;

  factory VehicleInfo.fromJson(Map<String, dynamic> json) =>
      _$VehicleInfoFromJson(json);
}