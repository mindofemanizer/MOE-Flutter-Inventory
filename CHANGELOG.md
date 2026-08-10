# Changelog

## 1.0.0 — 2026-08-10

### Added
- Initial release
- `InventoryItemModel` — stock tracking with quantityOnHand, reserved, available
- `WarehouseModel` — location management with capacity tracking
- `StockMovementModel` — inbound/outbound/transfers/adjustments tracking
- `InventoryRepository` — items/warehouses CRUD, stock movements, adjustments
- `WarehousesNotifier` — load/create warehouses
- `InventoryItemsNotifier` — load/search items, adjust quantities
- `StockMovementsNotifier` — record stock in/out, transfers
- `MoeInventoryConfig` — configurable API URL + multi-warehouse support
- Riverpod providers: `warehousesProvider`, `inventoryItemsProvider`, `stockMovementsProvider`

### Features
- Low stock alerts (`isLowStock`, `needsReorder`)
- Out of stock detection (`isOutOfStock`)
- Total value calculation (quantity × unitCost)
- Capacity usage percentage for warehouses
- Stock movement history with filtering
- Transfer between warehouses
- Reference linking (PO, SO, etc.)
