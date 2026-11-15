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
  ///
  /// Updates [isLoading], [errorMessage], and [vehicles], notifying listeners.
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
}

/// Shared repository instance for the application.
final vehicleRepository = VehicleRepository();

