// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleInfoImpl _$$VehicleInfoImplFromJson(Map<String, dynamic> json) =>
    _$VehicleInfoImpl(
      registrationNumber: json['registrationNumber'] as String,
      make: json['make'] as String?,
      model: json['model'] as String?,
      fuelType: json['fuelType'] as String?,
      bodyStyle: json['bodyStyle'] as String?,
      engineSize: json['engineSize'] as String?,
      year: (json['year'] as num?)?.toInt(),
      color: json['color'] as String?,
      vin: json['vin'] as String?,
      engineNumber: json['engineNumber'] as String?,
      engineCode: json['engineCode'] as String?,
      co2Emissions: (json['co2Emissions'] as num?)?.toInt(),
      transmission: json['transmission'] as String?,
      numberOfDoors: (json['numberOfDoors'] as num?)?.toInt(),
      euroStatus: json['euroStatus'] as String?,
      cylinderCapacity: json['cylinderCapacity'] as String?,
      power: (json['power'] as num?)?.toInt(),
      powerUnit: json['powerUnit'] as String?,
      description: json['description'] as String?,
      rawData: json['rawData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$VehicleInfoImplToJson(_$VehicleInfoImpl instance) =>
    <String, dynamic>{
      'registrationNumber': instance.registrationNumber,
      'make': instance.make,
      'model': instance.model,
      'fuelType': instance.fuelType,
      'bodyStyle': instance.bodyStyle,
      'engineSize': instance.engineSize,
      'year': instance.year,
      'color': instance.color,
      'vin': instance.vin,
      'engineNumber': instance.engineNumber,
      'engineCode': instance.engineCode,
      'co2Emissions': instance.co2Emissions,
      'transmission': instance.transmission,
      'numberOfDoors': instance.numberOfDoors,
      'euroStatus': instance.euroStatus,
      'cylinderCapacity': instance.cylinderCapacity,
      'power': instance.power,
      'powerUnit': instance.powerUnit,
      'description': instance.description,
      'rawData': instance.rawData,
    };
