import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_inventory/src/config/inventory_config.dart';
import 'package:moe_flutter_inventory/src/models/warehouse_model.dart';
import 'package:moe_flutter_inventory/src/models/inventory_item_model.dart';
import 'package:moe_flutter_inventory/src/models/stock_movement_model.dart';

/// Repository for inventory operations.
class InventoryRepository {
  final Dio _dio;
  final MoeInventoryConfig _config;

  InventoryRepository(this._dio, this._config);

  // ── Warehouses ─────────────────────────────────────────────

  /// List all warehouses.
  Future<AppResult<List<WarehouseModel>>> listWarehouses() async {
    try {
      final response = await _dio.get('/warehouses');
      final data = response.data as List<dynamic>;
      final warehouses = data
          .whereType<Map<String, dynamic>>()
          .map((w) => WarehouseModel.fromJson(w))
          .toList();
      return Ok(warehouses);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Create new warehouse.
  Future<AppResult<WarehouseModel>> createWarehouse({
    required String name,
    required String code,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? contactName,
    String? contactPhone,
    double capacity = 0.0,
  }) async {
    try {
      final response = await _dio.post('/warehouses', data: {
        'name': name,
        'code': code,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (province != null) 'province': province,
        if (postalCode != null) 'postal_code': postalCode,
        if (contactName != null) 'contact_name': contactName,
        if (contactPhone != null) 'contact_phone': contactPhone,
        'capacity': capacity,
      });
      return Ok(WarehouseModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Get single warehouse by ID.
  Future<AppResult<WarehouseModel>> getWarehouse(String id) async {
    try {
      final response = await _dio.get('/warehouses/$id');
      return Ok(WarehouseModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Update warehouse.
  Future<AppResult<void>> updateWarehouse(String id, {
    String? name,
    String? code,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? contactName,
    String? contactPhone,
    bool? isActive,
  }) async {
    try {
      await _dio.patch('/warehouses/$id', data: {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (province != null) 'province': province,
        if (postalCode != null) 'postal_code': postalCode,
        if (contactName != null) 'contact_name': contactName,
        if (contactPhone != null) 'contact_phone': contactPhone,
        if (isActive != null) 'is_active': isActive,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Delete warehouse.
  Future<AppResult<void>> deleteWarehouse(String id) async {
    try {
      await _dio.delete('/warehouses/$id');
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  // ── Inventory Items ────────────────────────────────────────

  /// List inventory items with filtering.
  Future<AppResult<List<InventoryItemModel>>> listItems({
    String? search,
    String? categoryCode,
    bool? onlyLowStock,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (categoryCode != null) 'category_code': categoryCode,
        if (onlyLowStock == true) 'only_low_stock': true,
      };
      final response = await _dio.get('/items', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((i) => InventoryItemModel.fromJson(i))
          .toList();
      return Ok(items);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Get single item by ID.
  Future<AppResult<InventoryItemModel>> getItem(String id) async {
    try {
      final response = await _dio.get('/items/$id');
      return Ok(InventoryItemModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Create new inventory item.
  Future<AppResult<InventoryItemModel>> createItem({
    required String sku,
    required String name,
    String? description,
    String? categoryId,
    double unitCost = 0.0,
    double reorderPoint = 0.0,
    List<String>? warehouseIds,
  }) async {
    try {
      final response = await _dio.post('/items', data: {
        'sku': sku,
        'name': name,
        if (description != null) 'description': description,
        if (categoryId != null) 'category_id': categoryId,
        'unit_cost': unitCost,
        'reorder_point': reorderPoint,
        if (warehouseIds != null && warehouseIds.isNotEmpty) 'warehouse_ids': warehouseIds,
      });
      return Ok(InventoryItemModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Update item quantity (adjust stock).
  Future<AppResult<void>> adjustQuantity(String itemId, {
    required double quantityChange,
    required String notes,
    String? referenceType,
    String? referenceId,
  }) async {
    try {
      await _dio.post('/items/$itemId/adjust-quantity', data: {
        'quantity_change': quantityChange,
        'notes': notes,
        if (referenceType != null) 'reference_type': referenceType,
        if (referenceId != null) 'reference_id': referenceId,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  // ── Stock Movements ────────────────────────────────────────

  /// List stock movements with filtering.
  Future<AppResult<List<StockMovementModel>>> listMovements({
    String? itemId,
    String? warehouseId,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? movementType,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (itemId != null) 'item_id': itemId,
        if (warehouseId != null) 'warehouse_id': warehouseId,
        if (fromWarehouseId != null) 'from_warehouse_id': fromWarehouseId,
        if (toWarehouseId != null) 'to_warehouse_id': toWarehouseId,
        if (movementType != null) 'type': movementType,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };
      final response = await _dio.get('/movements', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final movements = (data['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((m) => StockMovementModel.fromJson(m))
          .toList();
      return Ok(movements);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Record stock in (purchase restock, returns, etc.).
  Future<AppResult<void>> recordStockIn({
    required String itemId,
    required String warehouseId,
    required int quantity,
    required String referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      await _dio.post('/movements/in', data: {
        'item_id': itemId,
        'warehouse_id': warehouseId,
        'quantity': quantity,
        'reference_type': referenceType,
        if (referenceId != null) 'reference_id': referenceId,
        if (notes != null) 'notes': notes,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Record stock out (sales, consumption, etc.).
  Future<AppResult<void>> recordStockOut({
    required String itemId,
    required String warehouseId,
    required int quantity,
    required String referenceType,
    String? referenceId,
    String? notes,
  }) async {
    try {
      await _dio.post('/movements/out', data: {
        'item_id': itemId,
        'warehouse_id': warehouseId,
        'quantity': quantity,
        'reference_type': referenceType,
        if (referenceId != null) 'reference_id': referenceId,
        if (notes != null) 'notes': notes,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }

  /// Transfer stock between warehouses.
  Future<AppResult<void>> transferStock({
    required String itemId,
    required String fromWarehouseId,
    required String toWarehouseId,
    required int quantity,
    String? notes,
  }) async {
    try {
      await _dio.post('/movements/transfer', data: {
        'item_id': itemId,
        'from_warehouse_id': fromWarehouseId,
        'to_warehouse_id': toWarehouseId,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      });
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(
        type: FailureType.unknown,
        message: e.toString(),
      ));
    }
  }
}
