package com.stark.vms_backend.exception;

public class DuplicateVehicleNumberException extends RuntimeException {

    public DuplicateVehicleNumberException(String vehicleNumber) {
        super("Vehicle with number '" + vehicleNumber + "' already exists");
    }
}

