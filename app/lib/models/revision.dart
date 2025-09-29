import 'package:json_annotation/json_annotation.dart';

part 'revision.g.dart';

@JsonSerializable()
class Revision {
  final String id;
  final String equipmentId;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String createdBy;
  final bool isActive;

  Revision({
    required this.id,
    required this.equipmentId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.createdBy,
    this.isActive = true,
  });

  factory Revision.fromJson(Map<String, dynamic> json) => _$RevisionFromJson(json);
  Map<String, dynamic> toJson() => _$RevisionToJson(this);

  Revision copyWith({
    String? id,
    String? equipmentId,
    String? name,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    bool? isActive,
  }) {
    return Revision(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }

  bool isValidName() {
    return name.isNotEmpty && name.length <= 100;
  }

  String get displayName {
    final dateStr = createdAt.toIso8601String().split('T')[0];
    if (name.contains(dateStr)) {
      return name;
    }
    return '$dateStr - $name';
  }

  bool isOlderThan(Duration duration) {
    return DateTime.now().difference(createdAt) > duration;
  }

  bool isNewerThan(Duration duration) {
    return DateTime.now().difference(createdAt) < duration;
  }

  int compareTo(Revision other) {
    return createdAt.compareTo(other.createdAt);
  }
}