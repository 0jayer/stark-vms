import 'package:flutter/foundation.dart';

import '../models/vehicle.dart';
import '../services/api_client.dart';

/// Repository handling vehicle data operations from the Spring Boot backend.
///
/// Encapsulates all API interaction so widgets never perform raw HTTP calls.
class VehicleRepository extends ChangeNotifier {
  final ApiClient _apiClient;

  VehicleRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Unmodifiable view of currently loaded vehicles.
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  /// True while a fetch request is in progress.
  bool get isLoading => _isLoading;

  /// Human-readable error message if the last fetch failed, otherwise null.
  String? get errorMessage => _errorMessage;

  /// True if the last fetch resulted in an error.
  bool get hasError => _errorMessage != null;

  /// Fetches the vehicle list from `GET /api/vehicles`.
  /// Does NOT fall back to mock data if the request fails.
  Future<List<Vehicle>> getVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/api/vehicles');

      if (response is List) {
        _vehicles = response
            .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
            .toList();
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return _vehicles;
      }

      throw const FormatException(
        'Unexpected response format: Expected a JSON array of vehicles.',
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// `GET /api/vehicles/{id}`. Throws ApiException on failure.
  Future<Vehicle> getVehicle(int id) async {
    final response = await _apiClient.get('/api/vehicles/$id');
    return Vehicle.fromJson(response as Map<String, dynamic>);
  }

  /// `POST /api/vehicles`. Throws ApiException on 400/409/network errors.
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final response = await _apiClient.post('/api/vehicles', _body(vehicle));
    final created = Vehicle.fromJson(response as Map<String, dynamic>);
    _vehicles = [..._vehicles.where((v) => v.id != created.id), created];
    notifyListeners();
    return created;
  }

  /// `PUT /api/vehicles/{id}`. Throws ApiException on 400/404/409/network errors.
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    final response = await _apiClient.put(
      '/api/vehicles/${vehicle.id}',
      _body(vehicle),
    );
    final updated = Vehicle.fromJson(response as Map<String, dynamic>);
    _vehicles = _vehicles.map((v) => v.id == updated.id ? updated : v).toList();
    notifyListeners();
    return updated;
  }

  /// `DELETE /api/vehicles/{id}`. The local list changes only after the
  /// backend confirms success (204).
  Future<void> deleteVehicle(int id) async {
    await _apiClient.delete('/api/vehicles/$id');
    _vehicles = _vehicles.where((v) => v.id != id).toList();
    notifyListeners();
  }

  /// Request body per the backend contract: the model's JSON without the id.
  Map<String, dynamic> _body(Vehicle vehicle) {
    final json = vehicle.toJson();
    json.remove('id');
    return json;
  }
}

/// Shared repository instance for the application.
final vehicleRepository = VehicleRepository();
