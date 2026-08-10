/// Model representing an inventory item with stock tracking.
class InventoryItemModel extends Equatable {
  final String id;
  final String sku;
  final String name;
  final String? description;
  final String? categoryId;
  final String? categoryCode;
  final String? categoryName;
  final double quantityOnHand;
  final double reservedQuantity;
  final double availableQuantity;
  final double reorderPoint;
  final double? reorderQuantity;
  final List<String> warehouseIds;
  final DateTime lastCountDate;
  final double unitCost;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItemModel({
    required this.id,
    required this.sku,
    required this.name,
    this.description,
    this.categoryId,
    this.categoryCode,
    this.categoryName,
    this.quantityOnHand = 0.0,
    this.reservedQuantity = 0.0,
    required this.warehouseIds,
    this.lastCountDate,
    this.reorderPoint = 0.0,
    this.reorderQuantity,
    this.unitCost = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  })  : assert quantityOnHand >= 0,
        reservedQuantity >= 0,
        availableQuantity = quantityOnHand - reservedQuantity;

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      categoryCode: json['category_code'] as String?,
      categoryName: json['category_name'] as String?,
      quantityOnHand: (json['quantity_on_hand'] as num?)?.toDouble() ?? 0.0,
      reservedQuantity: (json['reserved_quantity'] as num?)?.toDouble() ?? 0.0,
      availableQuantity: (json['available_quantity'] as num?)?.toDouble() ?? 0.0,
      reorderPoint: (json['reorder_point'] as num?)?.toDouble() ?? 0.0,
      reorderQuantity: (json['reorder_quantity'] as num?)?.toDouble(),
      warehouseIds: (json['warehouse_ids'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      lastCountDate: json['last_count_date'] != null
          ? DateTime.parse(json['last_count_date'] as String)
          : null,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryCode != null) 'category_code': categoryCode,
      if (categoryName != null) 'category_name': categoryName,
      'quantity_on_hand': quantityOnHand,
      'reserved_quantity': reservedQuantity,
      'available_quantity': availableQuantity,
      'reorder_point': reorderPoint,
      if (reorderQuantity != null) 'reorder_quantity': reorderQuantity,
      'warehouse_ids': warehouseIds,
      if (lastCountDate != null) 'last_count_date': lastCountDate.toIso8601String(),
      'unit_cost': unitCost,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if item is out of stock.
  bool get isOutOfStock => availableQuantity <= 0;

  /// Check if item is low on stock (below reorder point).
  bool get isLowStock => availableQuantity > 0 && availableQuantity <= reorderPoint;

  /// Check if item needs reorder.
  bool get needsReorder => !isOutOfStock && availableQuantity <= reorderPoint;

  /// Total value (quantity × unit cost).
  double get totalValue => quantityOnHand * unitCost;

  /// Create copy with modifications.
  InventoryItemModel copyWith({
    String? id,
    String? sku,
    String? name,
    String? description,
    String? categoryId,
    String? categoryCode,
    String? categoryName,
    double? quantityOnHand,
    double? reservedQuantity,
    double? availableQuantity,
    double? reorderPoint,
    double? reorderQuantity,
    List<String>? warehouseIds,
    DateTime? lastCountDate,
    double? unitCost,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      reservedQuantity: reservedQuantity ?? this.reservedQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      warehouseIds: warehouseIds ?? this.warehouseIds,
      lastCountDate: lastCountDate ?? this.lastCountDate,
      unitCost: unitCost ?? this.unitCost,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        description,
        categoryId,
        categoryCode,
        categoryName,
        quantityOnHand,
        reservedQuantity,
        availableQuantity,
        reorderPoint,
        reorderQuantity,
        warehouseIds,
        lastCountDate,
        unitCost,
        isActive,
        createdAt,
        updatedAt,
      ];
}
