import 'package:equatable/equatable.dart';

/// Configuration for MOE Commerce module.
class MoeInventoryConfig extends Equatable {
  final String apiUrl;
  final bool enableMultiWarehouse;
  final int lowStockThreshold;

  const MoeInventoryConfig({
    required this.apiUrl,
    this.enableMultiWarehouse = true,
    this.lowStockThreshold = 10,
  });

  @override
  List<Object?> get props => [apiUrl, enableMultiWarehouse, lowStockThreshold];
}
