import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String deviceName;
  final String? companyId;
  final Map<String, dynamic> preferences;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final bool isActive;

  User({
    required this.id,
    required this.deviceName,
    this.companyId,
    Map<String, dynamic>? preferences,
    required this.firstSeen,
    required this.lastSeen,
    this.isActive = true,
  }) : preferences = preferences ?? {};

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? deviceName,
    String? companyId,
    Map<String, dynamic>? preferences,
    DateTime? firstSeen,
    DateTime? lastSeen,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      companyId: companyId ?? this.companyId,
      preferences: preferences ?? this.preferences,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isValidDeviceName() {
    return deviceName.isNotEmpty && deviceName.length <= 50;
  }

  T? getPreference<T>(String key, {T? defaultValue}) {
    if (preferences.containsKey(key)) {
      return preferences[key] as T?;
    }
    return defaultValue;
  }

  User updatePreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences[key] = value;
    return copyWith(preferences: newPreferences);
  }

  User removePreference(String key) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences.remove(key);
    return copyWith(preferences: newPreferences);
  }

  User updateLastSeen() {
    return copyWith(lastSeen: DateTime.now());
  }

  bool get syncEnabled => getPreference<bool>('syncEnabled', defaultValue: true) ?? true;
  bool get autoBackup => getPreference<bool>('autoBackup', defaultValue: true) ?? true;
  String get preferredTheme => getPreference<String>('theme', defaultValue: 'system') ?? 'system';
  bool get showPhotoTimestamps => getPreference<bool>('showPhotoTimestamps', defaultValue: true) ?? true;
  bool get enableGPSTracking => getPreference<bool>('enableGPSTracking', defaultValue: true) ?? true;
  int get photoThumbnailSize => getPreference<int>('photoThumbnailSize', defaultValue: 200) ?? 200;
  bool get quickCaptureMode => getPreference<bool>('quickCaptureMode', defaultValue: true) ?? true;
  String get defaultPhotoFolder => getPreference<String>('defaultPhotoFolder', defaultValue: 'Needs Assignment') ?? 'Needs Assignment';
  bool get vibrateOnCapture => getPreference<bool>('vibrateOnCapture', defaultValue: true) ?? true;
  int get maxOfflinePhotos => getPreference<int>('maxOfflinePhotos', defaultValue: 1000) ?? 1000;
  
  Duration get sessionDuration => lastSeen.difference(firstSeen);
  bool get isNewUser => sessionDuration.inDays < 7;
}