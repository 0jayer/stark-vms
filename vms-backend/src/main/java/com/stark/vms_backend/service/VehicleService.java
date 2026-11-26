package com.stark.vms_backend.service;

import com.stark.vms_backend.dto.VehicleRequest;
import com.stark.vms_backend.dto.VehicleResponse;
import com.stark.vms_backend.entity.Vehicle;
import com.stark.vms_backend.exception.DuplicateVehicleNumberException;
import com.stark.vms_backend.exception.VehicleNotFoundException;
import com.stark.vms_backend.repository.VehicleRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class VehicleService {

    private final VehicleRepository vehicleRepository;

    public VehicleService(VehicleRepository vehicleRepository) {
        this.vehicleRepository = vehicleRepository;
    }

    public VehicleResponse create(VehicleRequest request) {
        String normalizedNumber = normalizeVehicleNumber(request.getVehicleNumber());
        if (vehicleRepository.existsByVehicleNumber(normalizedNumber)) {
            throw new DuplicateVehicleNumberException(normalizedNumber);
        }

        Vehicle vehicle = new Vehicle(
                normalizedNumber,
                request.getCompany(),
                request.getType(),
                request.getBrand(),
                request.getModel(),
                request.getStatus()
        );

        Vehicle saved = vehicleRepository.save(vehicle);
        return mapToResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<VehicleResponse> list() {
        return vehicleRepository.findAll().stream()
                .map(this::mapToResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public VehicleResponse getById(Long id) {
        return vehicleRepository.findById(id)
                .map(this::mapToResponse)
                .orElseThrow(() -> new VehicleNotFoundException(id));
    }

    public VehicleResponse update(Long id, VehicleRequest request) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new VehicleNotFoundException(id));

        String normalizedNumber = normalizeVehicleNumber(request.getVehicleNumber());
        if (vehicleRepository.existsByVehicleNumberAndIdNot(normalizedNumber, id)) {
            throw new DuplicateVehicleNumberException(normalizedNumber);
        }

        vehicle.setVehicleNumber(normalizedNumber);
        vehicle.setCompany(request.getCompany());
        vehicle.setType(request.getType());
        vehicle.setBrand(request.getBrand());
        vehicle.setModel(request.getModel());
        vehicle.setStatus(request.getStatus());

        Vehicle saved = vehicleRepository.save(vehicle);
        return mapToResponse(saved);
    }

    public void delete(Long id) {
        if (!vehicleRepository.existsById(id)) {
            throw new VehicleNotFoundException(id);
        }
        vehicleRepository.deleteById(id);
    }

    private String normalizeVehicleNumber(String vehicleNumber) {
        return vehicleNumber != null ? vehicleNumber.trim().toUpperCase() : null;
    }

    private VehicleResponse mapToResponse(Vehicle vehicle) {
        return new VehicleResponse(
                vehicle.getId(),
                vehicle.getVehicleNumber(),
                vehicle.getCompany(),
                vehicle.getType(),
                vehicle.getBrand(),
                vehicle.getModel(),
                vehicle.getStatus()
        );
    }
}

