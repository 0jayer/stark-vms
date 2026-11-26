import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../models/vehicle.dart';
import '../repositories/vehicle_repository.dart';
import '../services/api_exception.dart';
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

  final _vehicleNumberController = TextEditingController();
  final _companyController = TextEditingController();
  final _typeController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  VehicleStatus _selectedStatus = VehicleStatus.active;

  bool _loadingExisting = false;
  String? _loadError;
  bool _saving = false;
  String? _formError;
  Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final id = int.tryParse(widget.vehicleId!);
    if (id == null) {
      setState(() => _loadError = 'Invalid vehicle id.');
      return;
    }
    setState(() {
      _loadingExisting = true;
      _loadError = null;
    });
    try {
      final v = await vehicleRepository.getVehicle(id);
      if (!mounted) return;
      setState(() {
        _vehicleNumberController.text = v.vehicleNumber;
        _companyController.text = v.company;
        _typeController.text = v.type;
        _brandController.text = v.brand;
        _modelController.text = v.model;
        _selectedStatus = v.status;
        _loadingExisting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingExisting = false;
        _loadError = e.toString();
      });
    }
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

  Future<void> _saveVehicle() async {
    setState(() {
      _serverErrors = {};
      _formError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.isEditing ? (int.tryParse(widget.vehicleId!) ?? 0) : 0,
      vehicleNumber: _vehicleNumberController.text.trim(),
      company: _companyController.text.trim(),
      type: _typeController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      status: _selectedStatus,
    );

    setState(() => _saving = true);

    try {
      final saved = widget.isEditing
          ? await vehicleRepository.updateVehicle(vehicle)
          : await vehicleRepository.createVehicle(vehicle);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Vehicle "${saved.vehicleNumber}" updated successfully'
                : 'Vehicle "${saved.vehicleNumber}" registered successfully',
          ),
          backgroundColor: AppTheme.deepBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/vehicles');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverErrors = e.fieldErrorStrings;
        // 400 shows messages under the fields; 409/404/network show a banner.
        _formError = _serverErrors.isEmpty ? e.message : null;
      });
      if (_serverErrors.isNotEmpty) _formKey.currentState!.validate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _formError = e.toString();
      });
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String fieldKey,
    required String label,
    required String hint,
    required IconData icon,
    required String requiredMessage,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return requiredMessage;
        return _serverErrors[fieldKey];
      },
    );
  }

  /// Row on wide screens, column on narrow ones.
  Widget _responsiveRow(List<Widget> fields, double breakpoint) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > breakpoint;
        final children = <Widget>[];
        for (var i = 0; i < fields.length; i++) {
          if (i > 0) {
            children.add(
              isDesktop
                  ? const SizedBox(width: 20)
                  : const SizedBox(height: 18),
            );
          }
          children.add(isDesktop ? Expanded(child: fields[i]) : fields[i]);
        }
        return isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              )
            : Column(children: children);
      },
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppTheme.errorRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingExisting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            _errorBanner(_loadError!),
            OutlinedButton.icon(
              onPressed: _loadExisting,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
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
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            if (_formError != null) _errorBanner(_formError!),

            _responsiveRow([
              _field(
                controller: _vehicleNumberController,
                fieldKey: 'vehicleNumber',
                label: 'Vehicle Number *',
                hint: 'e.g. STK-V-106',
                icon: Icons.pin_outlined,
                requiredMessage: 'Please enter a vehicle number',
              ),
              _field(
                controller: _companyController,
                fieldKey: 'company',
                label: 'Company *',
                hint: 'e.g. Stark Logistics',
                icon: Icons.business_outlined,
                requiredMessage: 'Please enter the owning company',
              ),
            ], 600),
            const SizedBox(height: 18),

            _responsiveRow([
              _field(
                controller: _typeController,
                fieldKey: 'type',
                label: 'Type *',
                hint: 'e.g. Sedan, SUV, Truck, Van',
                icon: Icons.category_outlined,
                requiredMessage: 'Please enter the vehicle type',
              ),
              _field(
                controller: _brandController,
                fieldKey: 'brand',
                label: 'Brand *',
                hint: 'e.g. Volvo, Toyota, Ford',
                icon: Icons.directions_car_outlined,
                requiredMessage: 'Please enter the brand',
              ),
              _field(
                controller: _modelController,
                fieldKey: 'model',
                label: 'Model *',
                hint: 'e.g. FH16, Camry, Explorer',
                icon: Icons.stars_outlined,
                requiredMessage: 'Please enter the model',
              ),
            ], 700),
            const SizedBox(height: 18),

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
                onChanged: _saving
                    ? null
                    : (newStatus) {
                        if (newStatus != null) {
                          setState(() => _selectedStatus = newStatus);
                        }
                      },
              ),
            ),
            const SizedBox(height: 36),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _saving ? null : () => context.go('/vehicles'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveVehicle,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(
                    widget.isEditing ? 'Save Changes' : 'Register Vehicle',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
          PageHeader(
            title: titleText,
            subtitle: subtitleText,
            onBack: () => context.go('/vehicles'),
          ),
          Card(child: _buildBody()),
        ],
      ),
    );
  }
}
