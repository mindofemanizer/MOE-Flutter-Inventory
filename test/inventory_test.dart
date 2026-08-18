import 'package:flutter_test/flutter_test.dart';
import 'package:moe_flutter_inventory/moe_flutter_inventory.dart';

void main() {
  group('MoeInventoryConfig', () {
    test('has correct defaults', () {
      const config = MoeInventoryConfig(
        apiUrl: 'https://api.example.com',
      );

      expect(config.apiUrl, equals('https://api.example.com'));
      expect(config.enableMultiWarehouse, isTrue);
      expect(config.lowStockThreshold, equals(10));
    });
  });

  group('InventoryItemModel', () {
    test('calculates availableQuantity', () {
      final item = InventoryItemModel(
        id: 'test',
        sku: 'SKU1',
        name: 'Product',
        quantityOnHand: 100,
        reservedQuantity: 30,
        warehouseIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.availableQuantity, equals(70));
    });

    test('isOutOfStock returns true when available <= 0', () {
      final item = InventoryItemModel(
        id: 'test',
        sku: 'SKU1',
        name: 'Product',
        quantityOnHand: 5,
        reservedQuantity: 10,
        warehouseIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.isOutOfStock, isTrue);
    });

    test('isLowStock returns true when below reorderPoint', () {
      final item = InventoryItemModel(
        id: 'test',
        sku: 'SKU1',
        name: 'Product',
        quantityOnHand: 5,
        reservedQuantity: 0,
        warehouseIds: [],
        reorderPoint: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.isLowStock, isTrue);
    });

    test('totalValue calculates correctly', () {
      final item = InventoryItemModel(
        id: 'test',
        sku: 'SKU1',
        name: 'Product',
        quantityOnHand: 10,
        unitCost: 5000,
        warehouseIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.totalValue, equals(50000));
    });

    test('fromJson parses fields correctly', () {
      final json = {
        'id': 'item1',
        'sku': 'SKU-001',
        'name': 'Test Product',
        'description': 'Test desc',
        'category_id': 'cat1',
        'category_code': 'CAT',
        'category_name': 'Category',
        'quantity_on_hand': 100,
        'reserved_quantity': 20,
        'available_quantity': 80,
        'reorder_point': 10,
        'reorder_quantity': 50,
        'warehouse_ids': ['wh1', 'wh2'],
        'unit_cost': 1000,
        'is_active': true,
        'created_at': '2026-08-10T10:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
        'last_count_date': '2026-08-09T10:00:00.000Z',
      };

      final item = InventoryItemModel.fromJson(json);

      expect(item.id, equals('item1'));
      expect(item.sku, equals('SKU-001'));
      expect(item.name, equals('Test Product'));
      expect(item.description, equals('Test desc'));
      expect(item.categoryId, equals('cat1'));
      expect(item.categoryCode, equals('CAT'));
      expect(item.categoryName, equals('Category'));
      expect(item.quantityOnHand, equals(100));
      expect(item.reservedQuantity, equals(20));
      expect(item.availableQuantity, equals(80));
      expect(item.reorderPoint, equals(10));
      expect(item.reorderQuantity, equals(50));
      expect(item.warehouseIds, equals(['wh1', 'wh2']));
      expect(item.unitCost, equals(1000));
      expect(item.isActive, isTrue);
      expect(item.lastCountDate, isNotNull);
      expect(item.needsReorder, isFalse);
    });
  });

  group('StockMovementModel', () {
    test('isInbound returns true for in movements', () {
      final movement = StockMovementModel(
        id: 'mov1',
        itemId: 'item1',
        itemName: 'Test',
        sku: 'S1',
        type: 'in',
        quantity: 10,
        createdBy: 'user1',
        occurredAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(movement.isInbound, isTrue);
      expect(movement.isOutbound, isFalse);
    });

    test('isOutbound returns true for out movements', () {
      final movement = StockMovementModel(
        id: 'mov1',
        itemId: 'item1',
        itemName: 'Test',
        sku: 'S1',
        type: 'out',
        quantity: 5,
        createdBy: 'user1',
        occurredAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(movement.isInbound, isFalse);
      expect(movement.isOutbound, isTrue);
    });

    test('isTransfer returns true for transfer movements', () {
      final movement = StockMovementModel(
        id: 'mov1',
        itemId: 'item1',
        itemName: 'Test',
        sku: 'S1',
        type: 'transfer',
        quantity: 3,
        fromWarehouseId: 'wh1',
        toWarehouseId: 'wh2',
        createdBy: 'user1',
        occurredAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(movement.isTransfer, isTrue);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'mov1',
        'item_id': 'item1',
        'item_name': 'Product',
        'sku': 'SKU1',
        'from_warehouse_id': 'wh1',
        'to_warehouse_id': 'wh2',
        'type': 'transfer',
        'quantity': 5,
        'reference_type': 'purchase_order',
        'reference_id': 'po-001',
        'notes': 'Restock from supplier',
        'created_by': 'admin',
        'occurred_at': '2026-08-10T10:00:00.000Z',
        'created_at': '2026-08-10T12:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
      };

      final movement = StockMovementModel.fromJson(json);

      expect(movement.id, equals('mov1'));
      expect(movement.itemId, equals('item1'));
      expect(movement.itemName, equals('Product'));
      expect(movement.sku, equals('SKU1'));
      expect(movement.fromWarehouseId, equals('wh1'));
      expect(movement.toWarehouseId, equals('wh2'));
      expect(movement.type, equals('transfer'));
      expect(movement.quantity, equals(5));
      expect(movement.referenceType, equals('purchase_order'));
      expect(movement.referenceId, equals('po-001'));
      expect(movement.notes, equals('Restock from supplier'));
      expect(movement.createdBy, equals('admin'));
      expect(movement.isTransfer, isTrue);
    });
  });

  group('WarehouseModel', () {
    test('capacityPercentage calculates correctly', () {
      final warehouse = WarehouseModel(
        id: 'wh1',
        name: 'Main Warehouse',
        code: 'WH-MAIN',
        capacity: 1000,
        currentCapacityUsage: 500,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(warehouse.capacityPercentage, equals(50.0));
    });

    test('isNearlyFull returns true when over 90%', () {
      final warehouse = WarehouseModel(
        id: 'wh1',
        name: 'Main Warehouse',
        code: 'WH-MAIN',
        capacity: 1000,
        currentCapacityUsage: 950,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(warehouse.isNearlyFull, isTrue);
    });

    test('fromJson parses warehouse', () {
      final json = {
        'id': 'wh1',
        'name': 'Jakarta Main',
        'code': 'WH-JKT',
        'address': 'Jl. Merdeka No. 1',
        'city': 'Jakarta',
        'province': 'DKI Jakarta',
        'postal_code': '10110',
        'contact_name': 'John Doe',
        'contact_phone': '081234567890',
        'capacity': 1000,
        'current_capacity_usage': 650,
        'is_active': true,
        'created_at': '2026-08-10T10:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
      };

      final warehouse = WarehouseModel.fromJson(json);

      expect(warehouse.id, equals('wh1'));
      expect(warehouse.name, equals('Jakarta Main'));
      expect(warehouse.code, equals('WH-JKT'));
      expect(warehouse.address, equals('Jl. Merdeka No. 1'));
      expect(warehouse.city, equals('Jakarta'));
      expect(warehouse.province, equals('DKI Jakarta'));
      expect(warehouse.postalCode, equals('10110'));
      expect(warehouse.contactName, equals('John Doe'));
      expect(warehouse.contactPhone, equals('081234567890'));
      expect(warehouse.capacity, equals(1000));
      expect(warehouse.currentCapacityUsage, equals(650));
      expect(warehouse.capacityPercentage, equals(65.0));
      expect(warehouse.isActive, isTrue);
    });

    test('copyWith updates fields', () {
      final warehouse = WarehouseModel(
        id: 'wh1',
        name: 'Main Warehouse',
        code: 'WH-MAIN',
        capacity: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = warehouse.copyWith(
        name: 'Updated Name',
        address: 'New Address',
        isActive: false,
      );

      expect(updated.name, equals('Updated Name'));
      expect(updated.address, equals('New Address'));
      expect(updated.isActive, isFalse);
      expect(updated.id, equals('wh1'));
    });
  });
}
