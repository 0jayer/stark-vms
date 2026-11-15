# Vehicle Management System (VMS) - Vehicle REST API

Base URL: `/api/vehicles`

---

## 1. Create Vehicle

- **Method**: `POST`
- **Path**: `/api/vehicles`
- **Description**: Creates a new vehicle. The vehicle number is automatically trimmed and converted to uppercase. Rejects duplicates case-insensitively.

### Request Body Example
```json
{
  "vehicleNumber": "CA-1234",
  "company": "Stark Logistics",
  "type": "Truck",
  "brand": "Ford",
  "model": "F-150",
  "status": "ACTIVE"
}
```

### Success Response (`201 Created`)
```json
{
  "id": 1,
  "vehicleNumber": "CA-1234",
  "company": "Stark Logistics",
  "type": "Truck",
  "brand": "Ford",
  "model": "F-150",
  "status": "ACTIVE"
}
```

### Common Error Responses

#### `400 Bad Request` - Validation Error
Returned when required fields are missing, blank, or exceed maximum allowed lengths.
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed for one or more fields",
  "fieldErrors": {
    "vehicleNumber": "Vehicle number is required",
    "status": "Status is required"
  }
}
```

#### `400 Bad Request` - Malformed JSON or Invalid Enum
Returned when the JSON cannot be parsed or an invalid status value is supplied.
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Malformed JSON request or invalid field value"
}
```

#### `409 Conflict` - Duplicate Vehicle Number
Returned when a vehicle with the given vehicle number already exists.
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 409,
  "error": "Conflict",
  "message": "Vehicle with number 'CA-1234' already exists"
}
```

---

## 2. List All Vehicles

- **Method**: `GET`
- **Path**: `/api/vehicles`
- **Description**: Retrieves all vehicles.

### Request Body
None.

### Success Response (`200 OK`)
```json
[
  {
    "id": 1,
    "vehicleNumber": "CA-1234",
    "company": "Stark Logistics",
    "type": "Truck",
    "brand": "Ford",
    "model": "F-150",
    "status": "ACTIVE"
  },
  {
    "id": 2,
    "vehicleNumber": "NY-5678",
    "company": "Wayne Enterprises",
    "type": "Van",
    "brand": "Mercedes",
    "model": "Sprinter",
    "status": "MAINTENANCE"
  }
]
```

---

## 3. Get Vehicle by ID

- **Method**: `GET`
- **Path**: `/api/vehicles/{id}`
- **Description**: Retrieves a single vehicle by its database identifier.

### Request Body
None.

### Success Response (`200 OK`)
```json
{
  "id": 1,
  "vehicleNumber": "CA-1234",
  "company": "Stark Logistics",
  "type": "Truck",
  "brand": "Ford",
  "model": "F-150",
  "status": "ACTIVE"
}
```

### Common Error Responses

#### `404 Not Found` - Vehicle Not Found
Returned when no vehicle exists with the specified ID.
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 404,
  "error": "Not Found",
  "message": "Vehicle with ID 99 not found"
}
```

---

## 4. Update Vehicle

- **Method**: `PUT`
- **Path**: `/api/vehicles/{id}`
- **Description**: Updates an existing vehicle. Updating to another vehicle's existing vehicle number is rejected with 409, but retaining the current vehicle's number is permitted.

### Request Body Example
```json
{
  "vehicleNumber": "CA-1234",
  "company": "Stark Logistics Updated",
  "type": "Truck",
  "brand": "Ford",
  "model": "F-250",
  "status": "MAINTENANCE"
}
```

### Success Response (`200 OK`)
```json
{
  "id": 1,
  "vehicleNumber": "CA-1234",
  "company": "Stark Logistics Updated",
  "type": "Truck",
  "brand": "Ford",
  "model": "F-250",
  "status": "MAINTENANCE"
}
```

### Common Error Responses

#### `400 Bad Request` - Validation Error
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed for one or more fields",
  "fieldErrors": {
    "company": "Company is required"
  }
}
```

#### `404 Not Found` - Vehicle Not Found
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 404,
  "error": "Not Found",
  "message": "Vehicle with ID 99 not found"
}
```

#### `409 Conflict` - Duplicate Vehicle Number
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 409,
  "error": "Conflict",
  "message": "Vehicle with number 'NY-5678' already exists"
}
```

---

## 5. Delete Vehicle

- **Method**: `DELETE`
- **Path**: `/api/vehicles/{id}`
- **Description**: Deletes a vehicle by its ID.

### Request Body
None.

### Success Response (`204 No Content`)
No response body.

### Common Error Responses

#### `404 Not Found` - Vehicle Not Found
```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 404,
  "error": "Not Found",
  "message": "Vehicle with ID 99 not found"
}
```

---

## 6. Generic Error Format

Any unhandled server exception yields a safe `500 Internal Server Error` without leaking stack traces or internal implementation details:

```json
{
  "timestamp": "2026-11-15T17:20:00Z",
  "status": 500,
  "error": "Internal Server Error",
  "message": "An unexpected internal server error occurred"
}
```

