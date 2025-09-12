// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartModelImpl _$$PartModelImplFromJson(Map<String, dynamic> json) =>
    _$PartModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      description: json['description'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      searchCount: (json['searchCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PartModelImplToJson(_$PartModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'synonyms': instance.synonyms,
      'description': instance.description,
      'isPopular': instance.isPopular,
      'searchCount': instance.searchCount,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$SearchPartsParamsImpl _$$SearchPartsParamsImplFromJson(
        Map<String, dynamic> json) =>
    _$SearchPartsParamsImpl(
      query: json['query'] as String,
      categoryFilter: json['categoryFilter'] as String?,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      onlyPopular: json['onlyPopular'] as bool? ?? false,
    );

Map<String, dynamic> _$$SearchPartsParamsImplToJson(
        _$SearchPartsParamsImpl instance) =>
    <String, dynamic>{
      'query': instance.query,
      'categoryFilter': instance.categoryFilter,
      'limit': instance.limit,
      'offset': instance.offset,
      'onlyPopular': instance.onlyPopular,
    };

_$PartStatisticsImpl _$$PartStatisticsImplFromJson(Map<String, dynamic> json) =>
    _$PartStatisticsImpl(
      category: json['category'] as String,
      totalParts: (json['totalParts'] as num).toInt(),
      popularParts: (json['popularParts'] as num).toInt(),
      totalSearches: (json['totalSearches'] as num).toInt(),
      avgSearches: (json['avgSearches'] as num).toDouble(),
    );

Map<String, dynamic> _$$PartStatisticsImplToJson(
        _$PartStatisticsImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'totalParts': instance.totalParts,
      'popularParts': instance.popularParts,
      'totalSearches': instance.totalSearches,
      'avgSearches': instance.avgSearches,
    };
