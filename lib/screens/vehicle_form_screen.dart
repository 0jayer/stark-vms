import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../data/mock_vehicles.dart';
import '../models/vehicle.dart';
import '../widgets/page_header.dart';

/// Screen for registering a new fleet vehicle or editing an existing one.
class VehicleFormScreen extends StatefulWidget {
  final String? vehicleId;

  const VehicleFormScreen({super.key, this.vehicleId});

  bool get isEditing => vehicleId != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _companyController;
  late final TextEditingController _typeController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  VehicleStatus _selectedStatus = VehicleStatus.active;

  @override
  void initState() {
    super.initState();
    Vehicle? existing;
    if (widget.isEditing) {
      existing = vehicleStore.findById(widget.vehicleId!);
    }

    _vehicleNumberController = TextEditingController(text: existing?.vehicleNumber ?? '');
    _companyController = TextEditingController(text: existing?.company ?? '');
    _typeController = TextEditingController(text: existing?.type ?? '');
    _brandController = TextEditingController(text: existing?.brand ?? '');
    _modelController = TextEditingController(text: existing?.model ?? '');
    _selectedStatus = existing?.status ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _companyController.dispose();
    _typeController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final vehicleNumber = _vehicleNumberController.text.trim();
    final company = _companyController.text.trim();
    final type = _typeController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();

    if (widget.isEditing) {
      final updated = Vehicle(
        id: int.tryParse(widget.vehicleId!) ?? 0,
        vehicleNumber: vehicleNumber,
        company: company,
        type: type,
        brand: brand,
        model: model,
        status: _selectedStatus,
      );
      vehicleStore.update(updated);
    } else {
      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch,
        vehicleNumber: vehicleNumber,
        company: company,
        type: type,
        brand: brand,
        model: model,
        status: _selectedStatus,
      );
      vehicleStore.add(newVehicle);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEditing
              ? 'Vehicle "$vehicleNumber" updated successfully'
              : 'Vehicle "$vehicleNumber" registered successfully',
        ),
        backgroundColor: AppTheme.deepBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.go('/vehicles');
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.isEditing ? 'Edit Vehicle' : 'Register Vehicle';
    final subtitleText = widget.isEditing
        ? 'Update company vehicle specifications and operational status.'
        : 'Enter vehicle details to add it to the corporate fleet directory.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Page Header
          PageHeader(
            title: titleText,
            subtitle: subtitleText,
            onBack: () => context.go('/vehicles'),
          ),

          // Main Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All fields marked with an asterisk (*) are mandatory.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Row 1: Vehicle Number & Company
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 600;

                        if (isDesktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _vehicleNumberController,
                                  decoration: const InputDecoration(
                                    labelText: 'Vehicle Number *',
                                    hintText: 'e.g. STK-V-106',
                                    prefixIcon: Icon(Icons.pin_outlined, size: 20),
                                  ),
                                  validator: (val) => (val == null || val.trim().isEmpty)
                                      ? 'Please enter a vehicle number'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  controller: _companyController,
                                  decoration: const InputDecoration(
                                    labelText: 'Company *',
                                    hintText: 'e.g. Stark Logistics',
                                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                                  ),
                                  validator: (val) => (val == null || val.trim().isEmpty)
                                      ? 'Please enter the owning company'
                                      : null,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              TextFormField(
                                controller: _vehicleNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Vehicle Number *',
                                  hintText: 'e.g. STK-V-106',
                                  prefixIcon: Icon(Icons.pin_outlined, size: 20),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty)
                                    ? 'Please enter a vehicle number'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _companyController,
                                decoration: const InputDecoration(
                                  labelText: 'Company *',
                                  hintText: 'e.g. Stark Logistics',
                                  prefixIcon: Icon(Icons.business_outlined, size: 20),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty)
                                    ? 'Please enter the owning company'
                                    : null,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Row 2: Type, Brand & Model
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth > 700;

                        if (isDesktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _typeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Type *',
                                    hintText: 'e.g. Sedan, SUV, Truck, Van',
                                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                                  ),
                                  validator: (val) => (val == null || val.trim().isEmpty)
                                      ? 'Please enter the vehicle type'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  controller: _brandController,
                                  decoration: const InputDecoration(
                                    labelText: 'Brand *',
                                    hintText: 'e.g. Volvo, Toyota, Ford',
                                    prefixIcon: Icon(Icons.directions_car_outlined, size: 20),
                                  ),
                                  validator: (val) => (val == null || val.trim().isEmpty)
                                      ? 'Please enter the brand'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  controller: _modelController,
                                  decoration: const InputDecoration(
                                    labelText: 'Model *',
                                    hintText: 'e.g. FH16, Camry, Explorer',
                                    prefixIcon: Icon(Icons.stars_outlined, size: 20),
                                  ),
                                  validator: (val) => (val == null || val.trim().isEmpty)
                                      ? 'Please enter the model'
                                      : null,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              TextFormField(
                                controller: _typeController,
                                decoration: const InputDecoration(
                                  labelText: 'Type *',
                                  hintText: 'e.g. Sedan, SUV, Truck, Van',
                                  prefixIcon: Icon(Icons.category_outlined, size: 20),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty)
                                    ? 'Please enter the vehicle type'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _brandController,
                                decoration: const InputDecoration(
                                  labelText: 'Brand *',
                                  hintText: 'e.g. Volvo, Toyota, Ford',
                                  prefixIcon: Icon(Icons.directions_car_outlined, size: 20),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty)
                                    ? 'Please enter the brand'
                                    : null,
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _modelController,
                                decoration: const InputDecoration(
                                  labelText: 'Model *',
                                  hintText: 'e.g. FH16, Camry, Explorer',
                                  prefixIcon: Icon(Icons.stars_outlined, size: 20),
                                ),
                                validator: (val) => (val == null || val.trim().isEmpty)
                                    ? 'Please enter the model'
                                    : null,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Row 3: Status
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: DropdownButtonFormField<VehicleStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Operational Status',
                          prefixIcon: Icon(Icons.info_outline, size: 20),
                        ),
                        items: VehicleStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            setState(() => _selectedStatus = newStatus);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Action Buttons (aligned right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.go('/vehicles'),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        FilledButton.icon(
                          onPressed: _saveVehicle,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(widget.isEditing ? 'Save Changes' : 'Register Vehicle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
