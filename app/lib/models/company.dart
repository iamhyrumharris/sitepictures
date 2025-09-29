import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  final String id;
  final String name;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Company({
    required this.id,
    required this.name,
    Map<String, dynamic>? settings,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  }) : settings = settings ?? {};

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  Company copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isValidName() {
    return name.isNotEmpty && name.length <= 100;
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    if (settings.containsKey(key)) {
      return settings[key] as T?;
    }
    return defaultValue;
  }

  Company updateSetting(String key, dynamic value) {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings[key] = value;
    return copyWith(settings: newSettings);
  }

  Company removeSetting(String key) {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings.remove(key);
    return copyWith(settings: newSettings);
  }

  bool get syncEnabled => getSetting<bool>('syncEnabled', defaultValue: true) ?? true;
  int get syncIntervalMinutes => getSetting<int>('syncIntervalMinutes', defaultValue: 30) ?? 30;
  int get maxPhotosPerSync => getSetting<int>('maxPhotosPerSync', defaultValue: 100) ?? 100;
  bool get autoAssignByGPS => getSetting<bool>('autoAssignByGPS', defaultValue: true) ?? true;
  int get photoQuality => getSetting<int>('photoQuality', defaultValue: 95) ?? 95;
  bool get keepOriginalPhotos => getSetting<bool>('keepOriginalPhotos', defaultValue: true) ?? true;
  String get defaultPhotoNamingPattern => 
      getSetting<String>('defaultPhotoNamingPattern', defaultValue: '{equipment}_{timestamp}') ?? 
      '{equipment}_{timestamp}';
}