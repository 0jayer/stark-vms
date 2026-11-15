/// The operational status of a vehicle.
enum VehicleStatus {
  active('Active'),
  inactive('Inactive'),
  maintenance('Maintenance');

  final String label;
  const VehicleStatus(this.label);
}

/// Represents a vehicle entity in the Vehicle Management System.
class Vehicle {
  final String id;
  final String vehicleNumber;
  final String company;
  final String type;
  final String brand;
  final String model;
  final VehicleStatus status;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    required this.company,
    required this.type,
    required this.brand,
    required this.model,
    this.status = VehicleStatus.active,
  });

  /// Creates a copy of this vehicle with optional replacement fields.
  Vehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? company,
    String? type,
    String? brand,
    String? model,
    VehicleStatus? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      company: company ?? this.company,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      status: status ?? this.status,
    );
  }
}
