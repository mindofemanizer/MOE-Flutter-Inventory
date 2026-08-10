/// Model representing a warehouse/location.
class WarehouseModel extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? contactName;
  final String? contactPhone;
  final double capacity;
  final double currentCapacityUsage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WarehouseModel({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.contactName,
    this.contactPhone,
    required this.capacity,
    this.currentCapacityUsage = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      province: json['province'] as String?,
      postalCode: json['postal_code'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      capacity: (json['capacity'] as num).toDouble(),
      currentCapacityUsage: json['current_capacity_usage'] != null
          ? (json['current_capacity_usage'] as num).toDouble()
          : 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (province != null) 'province': province,
      if (postalCode != null) 'postal_code': postalCode,
      if (contactName != null) 'contact_name': contactName,
      if (contactPhone != null) 'contact_phone': contactPhone,
      'capacity': capacity,
      'current_capacity_usage': currentCapacityUsage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Capacity usage percentage.
  double get capacityPercentage => capacity > 0
      ? (currentCapacityUsage / capacity) * 100
      : 0.0;

  /// Check if warehouse is nearly full (over 90% capacity).
  bool get isNearlyFull => capacityPercentage > 90.0;

  /// Create copy with modifications.
  WarehouseModel copyWith({
    String? id,
    String? name,
    String? code,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? contactName,
    String? contactPhone,
    double? capacity,
    double? currentCapacityUsage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WarehouseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      capacity: capacity ?? this.capacity,
      currentCapacityUsage: currentCapacityUsage ?? this.currentCapacityUsage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        address,
        city,
        province,
        postalCode,
        contactName,
        contactPhone,
        capacity,
        currentCapacityUsage,
        isActive,
        createdAt,
        updatedAt,
      ];
}
