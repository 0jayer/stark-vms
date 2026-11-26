package com.stark.vms_backend.exception;

public class VehicleNotFoundException extends RuntimeException {

    public VehicleNotFoundException(Long id) {
        super("Vehicle with ID " + id + " not found");
    }
}

