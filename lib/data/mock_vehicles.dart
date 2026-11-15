import '../models/vehicle.dart';

/// Static mock data for development and testing.
/// Replace this with real API calls when the backend is ready.
final List<Vehicle> mockVehicles = [
  const Vehicle(
    id: '1',
    make: 'Toyota',
    model: 'Camry',
    year: 2023,
    color: 'White',
    licensePlate: 'DHK-1234',
    status: VehicleStatus.available,
  ),
  const Vehicle(
    id: '2',
    make: 'Honda',
    model: 'Civic',
    year: 2022,
    color: 'Black',
    licensePlate: 'DHK-5678',
    status: VehicleStatus.inUse,
  ),
  const Vehicle(
    id: '3',
    make: 'Ford',
    model: 'Explorer',
    year: 2024,
    color: 'Silver',
    licensePlate: 'DHK-9012',
    status: VehicleStatus.available,
  ),
  const Vehicle(
    id: '4',
    make: 'BMW',
    model: 'X5',
    year: 2023,
    color: 'Blue',
    licensePlate: 'DHK-3456',
    status: VehicleStatus.maintenance,
  ),
  const Vehicle(
    id: '5',
    make: 'Mercedes',
    model: 'C-Class',
    year: 2021,
    color: 'Red',
    licensePlate: 'DHK-7890',
    status: VehicleStatus.available,
  ),
];

