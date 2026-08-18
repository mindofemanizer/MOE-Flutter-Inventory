# MOE-Flutter-Inventory

Inventory package for MOE Flutter ecosystem â€” inventory items, warehouses, stock movements.

## Installation

```yaml
dependencies:
  moe_flutter_inventory:
    git:
      url: https://github.com/mindofemanizer/MOE-Flutter-Inventory.git
      ref: v1.0.0
```

## Usage

### Setup

```dart
import 'package:moe_flutter_foundation/moe_flutter_foundation.dart';
import 'package:moe_flutter_inventory/moe_flutter_inventory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await MoeFoundation.setup(
    envConfig: EnvConfig.fromEnvironment(),
    sharedPreferences: prefs,
  );

  MoeInventory.setup(
    config: MoeInventoryConfig(
      apiUrl: 'https://api.kioskit.com/api/inventory',
      enableMultiWarehouse: true,
      lowStockThreshold: 10,
    ),
  );

  runApp(MoeFoundationProviderScope(child: MyApp()));
}
```

### Warehouses

```dart
final state = ref.watch(warehousesProvider.notifier);

// Load warehouses
await ref.read(warehousesProvider.notifier).loadWarehouses();

// Create new warehouse
final result = await ref.read(warehousesProvider.notifier).createWarehouse(
  name: 'Jakarta Main',
  code: 'WH-JKT',
  address: 'Jl. Merdeka No. 1',
  city: 'Jakarta',
  province: 'DKI Jakarta',
  postalCode: '10110',
  contactName: 'John Doe',
  contactPhone: '081234567890',
  capacity: 10000,
);

// Check capacity usage
if (result is Ok && state is WarehousesLoaded) {
  for (var wh in state.warehouses) {
    print('Capacity: ${wh.capacityPercentage}%');
    
    if (wh.isNearlyFull) {
      // Alert user
    }
  }
}
```

### Inventory Items

```dart
final state = ref.watch(inventoryItemsProvider);

// List items with search/filter
await ref.read(inventoryItemsProvider.notifier).loadItems(
  search: 'product name',
  categoryCode: 'CAT001',
  onlyLowStock: true,
);

// Check stock status
switch (state) {
  case InventoryItemsLoaded(:final items):
    for (var item in items) {
      if (item.isOutOfStock) {
        print('Out of stock: ${item.sku}');
      } else if (item.isLowStock) {
        print('Low stock: ${item.sku} (${item.availableQuantity})');
      } else if (item.needsReorder) {
        print('Needs reorder: ${item.sku} (${item.reorderQuantity})');
      }
      
      print('Total value: Rp ${Formatters.currency(item.totalValue)}');
    }
  default:
    // loading/error
}

// Adjust quantity (manual adjustment)
await ref.read(inventoryItemsProvider.notifier).adjustQuantity(
  'item_123',
  quantityChange: -5, // decrease by 5
  notes: 'Physical count adjustment',
  referenceType: 'physical_count',
);
```

### Stock Movements

```dart
final state = ref.watch(stockMovementsProvider.notifier);

// Record stock in (restock, returns, etc.)
await ref.read(stockMovementsProvider.notifier).recordIn(
  itemId: 'item_123',
  warehouseId: 'wh_main',
  quantity: 100,
  referenceType: 'purchase_order',
  referenceId: 'PO-2026-001',
  notes: 'Restock from supplier ABC',
);

// Record stock out (sales, consumption, etc.)
await ref.read(stockMovementsProvider.notifier).recordOut(
  itemId: 'item_123',
  warehouseId: 'wh_main',
  quantity: 10,
  referenceType: 'sale_order',
  referenceId: 'SO-2026-001',
  notes: 'Customer order fulfillment',
);

// Transfer between warehouses
await ref.read(stockMovementsProvider.notifier).transfer(
  itemId: 'item_123',
  fromWarehouseId: 'wh_jakarta',
  toWarehouseId: 'wh_surabaya',
  quantity: 50,
  notes: 'Rebalance stock',
);

// Load movement history
await ref.read(stockMovementsProvider.notifier).loadMovements(
  itemId: 'item_123',
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2026, 8, 10),
);
```

## What's Included

| Module | Description |
|--------|-------------|
| `InventoryItemModel` | Item data with stock tracking (onHand, reserved, available) |
| `WarehouseModel` | Location/warehouse with capacity and contact info |
| `StockMovementModel` | Inbound/outbound/transfer/adjustment tracking |
| `InventoryRepository` | Full CRUD for items/warehouses, stock movement APIs |
| `InventoryItemsNotifier` | Load/search items, adjust quantities |
| `WarehousesNotifier` | Load/create/update/delete warehouses |
| `StockMovementsNotifier` | Record movements, filter history |

## Stock Status Helpers

- `isOutOfStock` â€” available â‰¤ 0
- `isLowStock` â€” available > 0 but â‰¤ reorderPoint
- `needsReorder` â€” same as isLowStock
- `totalValue` â€” quantityOnHand Ã— unitCost
- `capacityPercentage` â€” currentUsage / capacity Ã— 100
- `isNearlyFull` â€” capacityPercentage > 90%
