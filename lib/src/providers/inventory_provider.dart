import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_inventory/src/config/inventory_config.dart';
import 'package:moe_flutter_inventory/src/models/warehouse_model.dart';
import 'package:moe_flutter_inventory/src/models/inventory_item_model.dart';
import 'package:moe_flutter_inventory/src/models/stock_movement_model.dart';
import 'package:moe_flutter_inventory/src/services/inventory_repository.dart';

/// State for warehouse operations.
sealed class WarehouseState {
  const WarehouseState();
}

final class WarehouseInitial extends WarehouseState {}

final class WarehouseLoading extends WarehouseState {}

final class WarehousesLoaded extends WarehouseState {
  final List<WarehouseModel> warehouses;
  const WarehousesLoaded(this.warehouses);
}

final class WarehouseError extends WarehouseState {
  final AppFailure failure;
  const WarehouseError(this.failure);
}

/// Notifier for warehouses.
class WarehousesNotifier extends StateNotifier<WarehouseState> {
  final InventoryRepository _repository;

  WarehousesNotifier(this._repository) : super(const WarehouseInitial());

  Future<void> loadWarehouses() async {
    state = const WarehouseLoading();

    final result = await _repository.listWarehouses();

    switch (result) {
      case Ok(:final data):
        state = WarehousesLoaded(data);
      case Err(:final failure):
        state = WarehouseError(failure);
    }
  }

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
    final result = await _repository.createWarehouse(
      name: name,
      code: code,
      address: address,
      city: city,
      province: province,
      postalCode: postalCode,
      contactName: contactName,
      contactPhone: contactPhone,
      capacity: capacity,
    );

    if (result is Ok && state is WarehousesLoaded) {
      final loaded = state as WarehousesLoaded;
      state = WarehousesLoaded([...loaded.warehouses, result.data]);
    }

    return result;
  }
}

/// State for inventory items.
sealed class InventoryItemsState {
  const InventoryItemsState();
}

final class InventoryItemsInitial extends InventoryItemsState {}

final class InventoryItemsLoading extends InventoryItemsState {}

final class InventoryItemsLoaded extends InventoryItemsState {
  final List<InventoryItemModel> items;
  const InventoryItemsLoaded(this.items);
}

final class InventoryItemsError extends InventoryItemsState {
  final AppFailure failure;
  const InventoryItemsError(this.failure);
}

/// Notifier for inventory items.
class InventoryItemsNotifier extends StateNotifier<InventoryItemsState> {
  final InventoryRepository _repository;

  InventoryItemsNotifier(this._repository) : super(const InventoryItemsInitial());

  Future<void> loadItems({
    String? search,
    String? categoryCode,
    bool? onlyLowStock,
  }) async {
    state = const InventoryItemsLoading();

    final result = await _repository.listItems(
      search: search,
      categoryCode: categoryCode,
      onlyLowStock: onlyLowStock,
    );

    switch (result) {
      case Ok(:final data):
        state = InventoryItemsLoaded(data);
      case Err(:final failure):
        state = InventoryItemsError(failure);
    }
  }

  Future<InventoryItemModel?> getItem(String id) async {
    final result = await _repository.getItem(id);

    if (result is Ok) {
      return result.data;
    } else {
      return null;
    }
  }

  Future<AppResult<InventoryItemModel>> createItem({
    required String sku,
    required String name,
    String? description,
    String? categoryId,
    double unitCost = 0.0,
    double reorderPoint = 0.0,
    List<String>? warehouseIds,
  }) async {
    final result = await _repository.createItem(
      sku: sku,
      name: name,
      description: description,
      categoryId: categoryId,
      unitCost: unitCost,
      reorderPoint: reorderPoint,
      warehouseIds: warehouseIds,
    );

    if (result is Ok && state is InventoryItemsLoaded) {
      final loaded = state as InventoryItemsLoaded;
      state = InventoryItemsLoaded([...loaded.items, result.data]);
    }

    return result;
  }

  Future<void> adjustQuantity(
    String itemId, {
    required double quantityChange,
    required String notes,
    String? referenceType,
    String? referenceId,
  }) async {
    final result = await _repository.adjustQuantity(
      itemId,
      quantityChange: quantityChange,
      notes: notes,
      referenceType: referenceType,
      referenceId: referenceId,
    );

    if (result is Ok && state is InventoryItemsLoaded) {
      // Reload all items to refresh quantities
      await loadItems(search: null);
    }
  }
}

/// State for stock movements.
sealed class StockMovementsState {
  const StockMovementsState();
}

final class StockMovementsInitial extends StockMovementsState {}

final class StockMovementsLoading extends StockMovementsState {}

final class StockMovementsLoaded extends StockMovementsState {
  final List<StockMovementModel> movements;
  const StockMovementsLoaded(this.movements);
}

final class StockMovementsError extends StockMovementsState {
  final AppFailure failure;
  const StockMovementsError(this.failure);
}

/// Notifier for stock movements.
class StockMovementsNotifier extends StateNotifier<StockMovementsState> {
  final InventoryRepository _repository;

  StockMovementsNotifier(this._repository) : super(const StockMovementsInitial());

  Future<void> loadMovements({
    String? itemId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const StockMovementsLoading();

    final result = await _repository.listMovements(
      itemId: itemId,
      startDate: startDate,
      endDate: endDate,
    );

    switch (result) {
      case Ok(:final data):
        state = StockMovementsLoaded(data);
      case Err(:final failure):
        state = StockMovementsError(failure);
    }
  }

  Future<void> recordIn({
    required String itemId,
    required String warehouseId,
    required int quantity,
    required String referenceType,
    String? referenceId,
    String? notes,
  }) async {
    await _repository.recordStockIn(
      itemId: itemId,
      warehouseId: warehouseId,
      quantity: quantity,
      referenceType: referenceType,
      referenceId: referenceId,
      notes: notes,
    );
  }

  Future<void> recordOut({
    required String itemId,
    required String warehouseId,
    required int quantity,
    required String referenceType,
    String? referenceId,
    String? notes,
  }) async {
    await _repository.recordStockOut(
      itemId: itemId,
      warehouseId: warehouseId,
      quantity: quantity,
      referenceType: referenceType,
      referenceId: referenceId,
      notes: notes,
    );
  }

  Future<void> transfer({
    required String itemId,
    required String fromWarehouseId,
    required String toWarehouseId,
    required int quantity,
    String? notes,
  }) async {
    await _repository.transferStock(
      itemId: itemId,
      fromWarehouseId: fromWarehouseId,
      toWarehouseId: toWarehouseId,
      quantity: quantity,
      notes: notes,
    );
  }
}

/// Provider for InventoryRepository.
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  throw UnimplementedError('MoeInventory.setup() must be called before use.');
});

/// Provider for WarehousesNotifier.
final warehousesProvider = StateNotifierProviderFactory<WarehousesNotifier>(
  (ref) => WarehousesNotifier(ref.watch(inventoryRepositoryProvider)),
);

/// Provider for InventoryItemsNotifier.
final inventoryItemsProvider = StateNotifierProviderFactory<InventoryItemsNotifier>(
  (ref) => InventoryItemsNotifier(ref.watch(inventoryRepositoryProvider)),
);

/// Provider for StockMovementsNotifier.
final stockMovementsProvider = StateNotifierProviderFactory<StockMovementsNotifier>(
  (ref) => StockMovementsNotifier(ref.watch(inventoryRepositoryProvider)),
);
