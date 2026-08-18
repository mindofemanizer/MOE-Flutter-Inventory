import 'package:equatable/equatable.dart';

/// Type of stock movement.
sealed class StockMovementType {
  const StockMovementType();
  
  String get stringValue;
  
  factory StockMovementType.fromString(String value) {
    switch (value) {
      case 'in':
        return in_;
      case 'out':
        return out;
      case 'transfer':
        return transfer;
      case 'adjustment':
        return adjustment;
      default:
        throw Exception('Unknown movement type: $value');
    }
  }

  static const in_ = _StockMovementTypeIn();
  static const out = _StockMovementTypeOut();
  static const transfer = _StockMovementTypeTransfer();
  static const adjustment = _StockMovementTypeAdjustment();
}

class _StockMovementTypeIn extends StockMovementType {
  const _StockMovementTypeIn();
  @override
  String get stringValue => 'in';
}

class _StockMovementTypeOut extends StockMovementType {
  const _StockMovementTypeOut();
  @override
  String get stringValue => 'out';
}

class _StockMovementTypeTransfer extends StockMovementType {
  const _StockMovementTypeTransfer();
  @override
  String get stringValue => 'transfer';
}

class _StockMovementTypeAdjustment extends StockMovementType {
  const _StockMovementTypeAdjustment();
  @override
  String get stringValue => 'adjustment';
}

/// Model representing a stock movement record.
class StockMovementModel extends Equatable {
  final String id;
  final String itemId;
  final String itemName;
  final String sku;
  final String? fromWarehouseId;
  final String? toWarehouseId;
  final String type;
  final int quantity;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final String createdBy;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockMovementModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.sku,
    this.fromWarehouseId,
    this.toWarehouseId,
    required this.type,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.createdBy,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name'] as String,
      sku: json['sku'] as String,
      fromWarehouseId: json['from_warehouse_id'] as String?,
      toWarehouseId: json['to_warehouse_id'] as String?,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name': itemName,
      'sku': sku,
      if (fromWarehouseId != null) 'from_warehouse_id': fromWarehouseId,
      if (toWarehouseId != null) 'to_warehouse_id': toWarehouseId,
      'type': type,
      'quantity': quantity,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (notes != null) 'notes': notes,
      'created_by': createdBy,
      'occurred_at': occurredAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Is this an incoming movement (+stock)?
  bool get isInbound => type == StockMovementType.in_.stringValue;

  /// Is this an outgoing movement (-stock)?
  bool get isOutbound => type == StockMovementType.out.stringValue;

  /// Is this a transfer between warehouses?
  bool get isTransfer => type == StockMovementType.transfer.stringValue;

  /// Is this a manual adjustment?
  bool get isAdjustment => type == StockMovementType.adjustment.stringValue;

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        sku,
        fromWarehouseId,
        toWarehouseId,
        type,
        quantity,
        referenceType,
        referenceId,
        notes,
        createdBy,
        occurredAt,
        createdAt,
        updatedAt,
      ];
}
