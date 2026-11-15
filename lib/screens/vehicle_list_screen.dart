import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../data/mock_vehicles.dart';
import '../models/vehicle.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/page_header.dart';
import '../widgets/status_badge.dart';

/// Screen displaying the list of all company fleet vehicles.
class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  Future<void> _handleDelete(BuildContext context, Vehicle vehicle) async {
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      vehicleNumber: vehicle.vehicleNumber,
    );

    if (confirmed == true && context.mounted) {
      vehicleStore.delete(vehicle.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle "${vehicle.vehicleNumber}" removed successfully'),
          backgroundColor: AppTheme.deepBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vehicleStore,
      builder: (context, _) {
        final vehicles = vehicleStore.vehicles;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Header with main action button
              PageHeader(
                title: 'Fleet Vehicles',
                subtitle: 'Manage and monitor all ${vehicles.length} registered company vehicles.',
                action: FilledButton.icon(
                  onPressed: () => context.go('/vehicles/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register Vehicle'),
                ),
              ),

              // Table container
              Card(
                child: vehicles.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 64, horizontal: 24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 48,
                                color: AppTheme.textMuted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No vehicles currently registered',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepBlue,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Click "Register Vehicle" above to add your first fleet vehicle.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                columns: const [
                                  DataColumn(
                                    label: Text('Vehicle Number'),
                                  ),
                                  DataColumn(
                                    label: Text('Company'),
                                  ),
                                  DataColumn(
                                    label: Text('Type'),
                                  ),
                                  DataColumn(
                                    label: Text('Brand'),
                                  ),
                                  DataColumn(
                                    label: Text('Model'),
                                  ),
                                  DataColumn(
                                    label: Text('Status'),
                                  ),
                                  DataColumn(
                                    label: Text('Actions'),
                                  ),
                                ],
                                rows: vehicles.map((v) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          v.vehicleNumber,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.deepBlue,
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(v.company)),
                                      DataCell(Text(v.type)),
                                      DataCell(Text(v.brand)),
                                      DataCell(Text(v.model)),
                                      DataCell(StatusBadge(status: v.status)),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: AppTheme.corporateBlue,
                                              ),
                                              tooltip: 'Edit vehicle',
                                              onPressed: () => context.go('/vehicles/edit/${v.id}'),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: AppTheme.errorRed,
                                              ),
                                              tooltip: 'Delete vehicle',
                                              onPressed: () => _handleDelete(context, v),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
