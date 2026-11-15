import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_vehicles.dart';
import '../models/vehicle.dart';

/// Screen displaying the list of all registered vehicles in a responsive data table.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  // Local copy of mock data to support deleting/updating during current session
  late List<Vehicle> _vehicles;

  @override
  void initState() {
    super.initState();
    _vehicles = List.from(mockVehicles);
  }

  void _deleteVehicle(String id) {
    setState(() {
      _vehicles.removeWhere((v) => v.id == id);
      mockVehicles.removeWhere((v) => v.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle removed')),
    );
  }

  Widget _buildStatusChip(VehicleStatus status, ColorScheme colorScheme) {
    Color bg;
    Color fg;

    switch (status) {
      case VehicleStatus.available:
        bg = Colors.green.withValues(alpha: 0.15);
        fg = Colors.green.shade800;
        break;
      case VehicleStatus.inUse:
        bg = Colors.blue.withValues(alpha: 0.15);
        fg = Colors.blue.shade800;
        break;
      case VehicleStatus.maintenance:
        bg = Colors.orange.withValues(alpha: 0.15);
        fg = Colors.orange.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => context.go('/vehicles/new'),
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: _vehicles.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No vehicles found. Add your first vehicle!'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('License Plate')),
                              DataColumn(label: Text('Make & Model')),
                              DataColumn(label: Text('Year')),
                              DataColumn(label: Text('Color')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _vehicles.map((v) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    v.licensePlate,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  DataCell(Text('${v.make} ${v.model}')),
                                  DataCell(Text(v.year.toString())),
                                  DataCell(Text(v.color)),
                                  DataCell(_buildStatusChip(v.status, colorScheme)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20),
                                          tooltip: 'Edit',
                                          onPressed: () => context.go('/vehicles/edit/${v.id}'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          tooltip: 'Delete',
                                          onPressed: () => _deleteVehicle(v.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

