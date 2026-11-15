import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../services/api_exception.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/page_header.dart';
import '../widgets/status_badge.dart';

/// Screen displaying the list of all company fleet vehicles loaded from the backend.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    vehicleRepository.getVehicles().catchError((_) => <Vehicle>[]);
  }

  Future<void> _handleDelete(BuildContext context, Vehicle vehicle) async {
    final confirmed = await showConfirmDeleteDialog(
      context: context,
      vehicleNumber: vehicle.vehicleNumber,
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await vehicleRepository.deleteVehicle(vehicle.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehicle "${vehicle.vehicleNumber}" removed successfully',
          ),
          backgroundColor: AppTheme.deepBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildContent(
    bool isLoading,
    String? errorMessage,
    List<Vehicle> vehicles,
  ) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load vehicles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.deepBlue,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _loadVehicles,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (vehicles.isEmpty) {
      return const Padding(
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
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Vehicle Number')),
                DataColumn(label: Text('Company')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Brand')),
                DataColumn(label: Text('Model')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
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
                            onPressed: () =>
                                context.go('/vehicles/edit/${v.id}'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vehicleRepository,
      builder: (context, _) {
        final isLoading = vehicleRepository.isLoading;
        final errorMessage = vehicleRepository.errorMessage;
        final vehicles = vehicleRepository.vehicles;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Page Header with main action button
              PageHeader(
                title: 'Fleet Vehicles',
                subtitle: isLoading
                    ? 'Loading company vehicles...'
                    : 'Manage and monitor all ${vehicles.length} registered company vehicles.',
                action: FilledButton.icon(
                  onPressed: () => context.go('/vehicles/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register Vehicle'),
                ),
              ),

              // Table / state container card
              Card(child: _buildContent(isLoading, errorMessage, vehicles)),
            ],
          ),
        );
      },
    );
  }
}
