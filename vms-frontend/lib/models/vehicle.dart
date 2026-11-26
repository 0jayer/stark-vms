/// The operational status of a vehicle.
enum VehicleStatus {
  active('Active'),
  inactive('Inactive'),
  maintenance('Maintenance');

  final String label;
  const VehicleStatus(this.label);

  /// Maps backend status string (ACTIVE, MAINTENANCE, INACTIVE) to [VehicleStatus].
  static VehicleStatus fromBackendString(String? value) {
    switch (value?.trim().toUpperCase()) {
      case 'ACTIVE':
        return VehicleStatus.active;
      case 'MAINTENANCE':
        return VehicleStatus.maintenance;
      case 'INACTIVE':
        return VehicleStatus.inactive;
      default:
        return VehicleStatus.active;
    }
  }

  /// Converts this [VehicleStatus] to backend enum format (ACTIVE, MAINTENANCE, INACTIVE).
  String toBackendString() {
    switch (this) {
      case VehicleStatus.active:
        return 'ACTIVE';
      case VehicleStatus.maintenance:
        return 'MAINTENANCE';
      case VehicleStatus.inactive:
        return 'INACTIVE';
    }
  }
}

/// Represents a vehicle entity matching the Spring Boot backend contract.
class Vehicle {
  final int id;
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

  /// Deserializes a [Vehicle] from a backend JSON map.
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = (rawId is int) ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return Vehicle(
      id: id,
      vehicleNumber: json['vehicleNumber'] as String? ?? '',
      company: json['company'] as String? ?? '',
      type: json['type'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      status: VehicleStatus.fromBackendString(json['status'] as String?),
    );
  }

  /// Serializes this [Vehicle] to a backend JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'company': company,
      'type': type,
      'brand': brand,
      'model': model,
      'status': status.toBackendString(),
    };
  }

  /// Creates a copy of this vehicle with optional replacement fields.
  Vehicle copyWith({
    int? id,
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
