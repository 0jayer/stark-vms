import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_vehicles.dart';
import '../models/vehicle.dart';

/// Screen for adding a new vehicle or editing an existing one.
class VehicleFormScreen extends StatefulWidget {
  final String? vehicleId;

  const VehicleFormScreen({super.key, this.vehicleId});

  bool get isEditing => vehicleId != null;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _licensePlateController;
  VehicleStatus _selectedStatus = VehicleStatus.available;

  @override
  void initState() {
    super.initState();
    Vehicle? existingVehicle;
    if (widget.isEditing) {
      try {
        existingVehicle = mockVehicles.firstWhere((v) => v.id == widget.vehicleId);
      } catch (_) {
        existingVehicle = null;
      }
    }

    _makeController = TextEditingController(text: existingVehicle?.make ?? '');
    _modelController = TextEditingController(text: existingVehicle?.model ?? '');
    _yearController = TextEditingController(
      text: existingVehicle != null ? existingVehicle.year.toString() : DateTime.now().year.toString(),
    );
    _colorController = TextEditingController(text: existingVehicle?.color ?? '');
    _licensePlateController = TextEditingController(text: existingVehicle?.licensePlate ?? '');
    _selectedStatus = existingVehicle?.status ?? VehicleStatus.available;
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final year = int.tryParse(_yearController.text.trim()) ?? DateTime.now().year;

    if (widget.isEditing) {
      final index = mockVehicles.indexWhere((v) => v.id == widget.vehicleId);
      if (index != -1) {
        mockVehicles[index] = Vehicle(
          id: widget.vehicleId!,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: year,
          color: _colorController.text.trim(),
          licensePlate: _licensePlateController.text.trim(),
          status: _selectedStatus,
        );
      }
    } else {
      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        color: _colorController.text.trim(),
        licensePlate: _licensePlateController.text.trim(),
        status: _selectedStatus,
      );
      mockVehicles.add(newVehicle);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEditing ? 'Vehicle updated successfully' : 'Vehicle created successfully'),
      ),
    );

    context.go('/vehicles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Vehicle' : 'Register Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/vehicles'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isEditing ? 'Update Vehicle Details' : 'New Vehicle Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _licensePlateController,
                        decoration: const InputDecoration(
                          labelText: 'License Plate *',
                          hintText: 'e.g. DHK-1234',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a license plate' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _makeController,
                              decoration: const InputDecoration(
                                labelText: 'Make *',
                                hintText: 'e.g. Toyota',
                                prefixIcon: Icon(Icons.directions_car_outlined),
                              ),
                              validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a make' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Model *',
                                hintText: 'e.g. Camry',
                                prefixIcon: Icon(Icons.branding_watermark_outlined),
                              ),
                              validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a model' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              decoration: const InputDecoration(
                                labelText: 'Year *',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Enter a year';
                                final parsed = int.tryParse(value.trim());
                                if (parsed == null || parsed < 1900 || parsed > 2100) return 'Valid year required';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: const InputDecoration(
                                labelText: 'Color *',
                                hintText: 'e.g. White',
                                prefixIcon: Icon(Icons.palette_outlined),
                              ),
                              validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a color' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<VehicleStatus>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.info_outline),
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
                      const SizedBox(height: 32),
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
                            icon: const Icon(Icons.check),
                            label: Text(widget.isEditing ? 'Save Changes' : 'Register Vehicle'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
