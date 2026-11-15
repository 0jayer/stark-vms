package com.stark.vms_backend.controller;

import com.stark.vms_backend.dto.VehicleRequest;
import com.stark.vms_backend.dto.VehicleResponse;
import com.stark.vms_backend.entity.VehicleStatus;
import com.stark.vms_backend.exception.DuplicateVehicleNumberException;
import com.stark.vms_backend.exception.GlobalExceptionHandler;
import com.stark.vms_backend.exception.VehicleNotFoundException;
import com.stark.vms_backend.service.VehicleService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.ObjectMapper;

import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(VehicleController.class)
@Import(GlobalExceptionHandler.class)
class VehicleControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private VehicleService vehicleService;

    @Test
    void create_validRequest_returns201() throws Exception {
        VehicleRequest request = new VehicleRequest("CA-1234", "Stark Logistics", "Truck", "Ford", "F-150", VehicleStatus.ACTIVE);
        VehicleResponse response = new VehicleResponse(1L, "CA-1234", "Stark Logistics", "Truck", "Ford", "F-150", VehicleStatus.ACTIVE);

        when(vehicleService.create(any(VehicleRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.vehicleNumber", is("CA-1234")))
                .andExpect(jsonPath("$.company", is("Stark Logistics")))
                .andExpect(jsonPath("$.status", is("ACTIVE")));
    }

    @Test
    void create_validationError_returns400WithFieldErrors() throws Exception {
        VehicleRequest invalidRequest = new VehicleRequest("", "", "", "", "", null);

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status", is(400)))
                .andExpect(jsonPath("$.error", is("Bad Request")))
                .andExpect(jsonPath("$.fieldErrors.vehicleNumber", notNullValue()))
                .andExpect(jsonPath("$.fieldErrors.company", notNullValue()))
                .andExpect(jsonPath("$.fieldErrors.status", notNullValue()));
    }

    @Test
    void create_duplicateVehicleNumber_returns409() throws Exception {
        VehicleRequest request = new VehicleRequest("CA-1234", "Stark Logistics", "Truck", "Ford", "F-150", VehicleStatus.ACTIVE);

        when(vehicleService.create(any(VehicleRequest.class)))
                .thenThrow(new DuplicateVehicleNumberException("CA-1234"));

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status", is(409)))
                .andExpect(jsonPath("$.error", is("Conflict")))
                .andExpect(jsonPath("$.message", containsString("CA-1234")));
    }

    @Test
    void create_dataIntegrityViolation_returns409() throws Exception {
        VehicleRequest request = new VehicleRequest("CA-1234", "Stark Logistics", "Truck", "Ford", "F-150", VehicleStatus.ACTIVE);

        when(vehicleService.create(any(VehicleRequest.class)))
                .thenThrow(new DataIntegrityViolationException("duplicate key value"));

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status", is(409)))
                .andExpect(jsonPath("$.error", is("Conflict")))
                .andExpect(jsonPath("$.message", is("A vehicle with this vehicle number already exists")));
    }

    @Test
    void create_invalidStatusValue_returns400() throws Exception {
        String invalidJson = """
                {
                  "vehicleNumber": "CA-1234",
                  "company": "Stark Logistics",
                  "type": "Truck",
                  "brand": "Ford",
                  "model": "F-150",
                  "status": "FLYING"
                }
                """;

        mockMvc.perform(post("/api/vehicles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status", is(400)))
                .andExpect(jsonPath("$.error", is("Bad Request")))
                .andExpect(jsonPath("$.message", containsString("Malformed JSON request or invalid field value")));
    }

    @Test
    void list_returns200WithVehicleList() throws Exception {
        List<VehicleResponse> vehicles = List.of(
                new VehicleResponse(1L, "CA-1234", "Stark Logistics", "Truck", "Ford", "F-150", VehicleStatus.ACTIVE),
                new VehicleResponse(2L, "NY-5678", "Wayne Enterprises", "Van", "Mercedes", "Sprinter", VehicleStatus.MAINTENANCE)
        );

        when(vehicleService.list()).thenReturn(vehicles);

        mockMvc.perform(get("/api/vehicles"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].vehicleNumber", is("CA-1234")))
                .andExpect(jsonPath("$[1].vehicleNumber", is("NY-5678")));
    }

    @Test
    void getById_existingId_returns200() throws Exception {
        VehicleResponse response = new VehicleResponse(1L, "CA-1234", "Stark Logistics", "Truck", "Ford", "F-150", VehicleStatus.ACTIVE);

        when(vehicleService.getById(1L)).thenReturn(response);

        mockMvc.perform(get("/api/vehicles/{id}", 1L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.vehicleNumber", is("CA-1234")));
    }

    @Test
    void getById_nonExistingId_returns404() throws Exception {
        when(vehicleService.getById(99L)).thenThrow(new VehicleNotFoundException(99L));

        mockMvc.perform(get("/api/vehicles/{id}", 99L))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status", is(404)))
                .andExpect(jsonPath("$.error", is("Not Found")))
                .andExpect(jsonPath("$.message", containsString("99")));
    }

    @Test
    void update_validRequest_returns200() throws Exception {
        VehicleRequest request = new VehicleRequest("CA-1234", "Stark Logistics Updated", "Truck", "Ford", "F-250", VehicleStatus.MAINTENANCE);
        VehicleResponse response = new VehicleResponse(1L, "CA-1234", "Stark Logistics Updated", "Truck", "Ford", "F-250", VehicleStatus.MAINTENANCE);

        when(vehicleService.update(eq(1L), any(VehicleRequest.class))).thenReturn(response);

        mockMvc.perform(put("/api/vehicles/{id}", 1L)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.company", is("Stark Logistics Updated")))
                .andExpect(jsonPath("$.status", is("MAINTENANCE")));
    }

    @Test
    void delete_existingId_returns204() throws Exception {
        doNothing().when(vehicleService).delete(1L);

        mockMvc.perform(delete("/api/vehicles/{id}", 1L))
                .andExpect(status().isNoContent());
    }

    @Test
    void delete_nonExistingId_returns404() throws Exception {
        doThrow(new VehicleNotFoundException(99L)).when(vehicleService).delete(99L);

        mockMvc.perform(delete("/api/vehicles/{id}", 99L))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status", is(404)))
                .andExpect(jsonPath("$.error", is("Not Found")))
                .andExpect(jsonPath("$.message", containsString("99")));
    }
}
