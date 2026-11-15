import 'package:flutter/foundation.dart';
import '../models/vehicle.dart';

/// Initial mock vehicles matching Stark Group corporate standards.
final List<Vehicle> initialMockVehicles = [
  const Vehicle(
    id: '1',
    vehicleNumber: 'STK-V-101',
    company: 'Stark Logistics',
    type: 'Truck',
    brand: 'Volvo',
    model: 'FH16 Heavy',
    status: VehicleStatus.active,
  ),
  const Vehicle(
    id: '2',
    vehicleNumber: 'STK-V-102',
    company: 'Stark Industries',
    type: 'Sedan',
    brand: 'Mercedes-Benz',
    model: 'E-Class',
    status: VehicleStatus.active,
  ),
  const Vehicle(
    id: '3',
    vehicleNumber: 'STK-V-103',
    company: 'Stark Security',
    type: 'SUV',
    brand: 'Ford',
    model: 'Explorer Police',
    status: VehicleStatus.active,
  ),
  const Vehicle(
    id: '4',
    vehicleNumber: 'STK-V-104',
    company: 'Stark Logistics',
    type: 'Van',
    brand: 'Mercedes-Benz',
    model: 'Sprinter 3500',
    status: VehicleStatus.maintenance,
  ),
  const Vehicle(
    id: '5',
    vehicleNumber: 'STK-V-105',
    company: 'Stark Aerospace',
    type: 'Electric SUV',
    brand: 'Tesla',
    model: 'Model X',
    status: VehicleStatus.inactive,
  ),
];

/// Central in-memory state manager for vehicles.
///
/// Changes to the vehicle list immediately notify listeners and update the UI.
class VehicleStore extends ChangeNotifier {
  static final VehicleStore instance = VehicleStore._();

  VehicleStore._() : _vehicles = List.from(initialMockVehicles);

  final List<Vehicle> _vehicles;

  /// Unmodifiable view of current vehicles.
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  /// Find a vehicle by ID.
  Vehicle? findById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Register a new vehicle.
  void add(Vehicle vehicle) {
    _vehicles.add(vehicle);
    notifyListeners();
  }

  /// Update an existing vehicle.
  void update(Vehicle updated) {
    final index = _vehicles.indexWhere((v) => v.id == updated.id);
    if (index != -1) {
      _vehicles[index] = updated;
      notifyListeners();
    }
  }

  /// Delete a vehicle by ID.
  void delete(String id) {
    _vehicles.removeWhere((v) => v.id == id);
    notifyListeners();
  }
}

/// Global shortcut accessor to the in-memory store.
final vehicleStore = VehicleStore.instance;
