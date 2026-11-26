import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../widgets/page_header.dart';
import '../widgets/status_badge.dart';

/// Dashboard overview displaying fleet statistics and recently added vehicles from the backend.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    vehicleRepository.getVehicles().catchError((_) => <Vehicle>[]);
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
              // Page Header
              PageHeader(
                title: 'Fleet Dashboard',
                subtitle: isLoading
                    ? 'Loading fleet data from backend...'
                    : 'Real-time overview of Stark Group vehicles and operational status.',
                action: FilledButton.icon(
                  onPressed: () => context.go('/vehicles/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register Vehicle'),
                ),
              ),

              // Content based on state
              if (isLoading && vehicles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (errorMessage != null && vehicles.isEmpty)
                Card(
                  child: Padding(
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
                            'Failed to load dashboard data',
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
                  ),
                )
              else
                _buildDashboardContent(context, vehicles),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, List<Vehicle> vehicles) {
    final totalCount = vehicles.length;
    final activeCount = vehicles.where((v) => v.status == VehicleStatus.active).length;
    final maintenanceCount =
        vehicles.where((v) => v.status == VehicleStatus.maintenance).length;
    final inactiveCount =
        vehicles.where((v) => v.status == VehicleStatus.inactive).length;

    // Show up to the 5 most recently added vehicles
    final recentVehicles = vehicles.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary metric cards
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int columns = 1;
            if (width >= 1000) {
              columns = 4;
            } else if (width >= 560) {
              columns = 2;
            }

            final cardWidth = (width - ((columns - 1) * 16)) / columns;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMetricCard(
                  width: cardWidth,
                  title: 'Total Vehicles',
                  count: totalCount,
                  description: 'Total fleet size',
                  icon: Icons.local_shipping_outlined,
                  iconColor: AppTheme.deepBlue,
                  iconBg: AppTheme.neutralBg,
                ),
                _buildMetricCard(
                  width: cardWidth,
                  title: 'Active',
                  count: activeCount,
                  description: 'In service & ready',
                  icon: Icons.check_circle_outline,
                  iconColor: AppTheme.successGreen,
                  iconBg: AppTheme.successGreenBg,
                  isSuccess: true,
                ),
                _buildMetricCard(
                  width: cardWidth,
                  title: 'Maintenance',
                  count: maintenanceCount,
                  description: 'Scheduled or repair',
                  icon: Icons.build_outlined,
                  iconColor: AppTheme.maintenanceText,
                  iconBg: AppTheme.maintenanceBg,
                ),
                _buildMetricCard(
                  width: cardWidth,
                  title: 'Inactive',
                  count: inactiveCount,
                  description: 'Decommissioned or idle',
                  icon: Icons.pause_circle_outline,
                  iconColor: AppTheme.neutralText,
                  iconBg: AppTheme.neutralBg,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Recent Vehicles section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recently Added Vehicles',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBlue,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Latest additions to the company fleet registry.',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () => context.go('/vehicles'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All Vehicles'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Recent Vehicles Table Card
        Card(
          child: recentVehicles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  child: Center(
                    child: Text(
                      'No vehicles registered yet.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
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
                            DataColumn(label: Text('Vehicle Number')),
                            DataColumn(label: Text('Company')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Brand & Model')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: recentVehicles.map((v) {
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
                                DataCell(Text('${v.brand} ${v.model}')),
                                DataCell(StatusBadge(status: v.status)),
                                DataCell(
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
    );
  }

  Widget _buildMetricCard({
    required double width,
    required String title,
    required int count,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isSuccess = false,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSuccess ? AppTheme.successGreen : AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
