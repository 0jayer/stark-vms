/// Represents a vehicle in the management system.
class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final VehicleStatus status;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    this.status = VehicleStatus.available,
  });

  /// Creates a copy of this vehicle with the given fields replaced.
  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? color,
    String? licensePlate,
    VehicleStatus? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      status: status ?? this.status,
    );
  }
}

/// The current status of a vehicle.
enum VehicleStatus {
  available('Available'),
  inUse('In Use'),
  maintenance('Maintenance');

  /// Human-readable label for this status.
  final String label;
  const VehicleStatus(this.label);
}

