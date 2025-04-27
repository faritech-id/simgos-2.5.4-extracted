# BPJS Integration Reference for OpenMRS

This document outlines the BPJS (Badan Penyelenggara Jaminan Sosial) integration functionality from SIMGOS for porting to OpenMRS.

## Overview

BPJS is Indonesia's National Healthcare Insurance system. The integration provides various healthcare-related lookups and operations through BPJS's VClaim system.

## Core Features

### 1. Patient Verification and Lookup
#### Endpoints
- Search by BPJS Card Number (`/Peserta/peserta/nokartu/{noKartu}`)
- Search by NIK/National ID (`/Peserta/peserta/nik/{nik}`)

#### Data Structure
```json
{
    "metadata": {
        "message": "OK",
        "code": 200,
        "requestId": "hospital_code"
    },
    "response": {
        "peserta": {
            "noKartu": "string",
            "nik": "string",
            "norm": "string",
            "nama": "string",
            "pisa": "string",
            "sex": "string",
            "tglLahir": "YYYY-MM-DD",
            "tglCetakKartu": "YYYY-MM-DD",
            "kelasTanggungan": {
                "kdKelas": "string"
            }
        }
    }
}
```

### 2. Referral Management
#### Endpoints
- Search by BPJS Card (`/Rujukan/rujukan/peserta/{noKartu}`)
- Search by Referral Number (`/Rujukan/rujukan/{noRujukan}`)
- Search by Date (`/rujukan/tglrujuk/{tanggal}/query?start={start}&limit={limit}`)

#### Data Structure
```json
{
    "metadata": {
        "message": "OK",
        "code": 200,
        "requestId": "hospital_code"
    },
    "response": {
        "rujukan": {
            "diagnosa": {
                "kode": "string",
                "nama": "string"
            },
            "tglKunjungan": "YYYY-MM-DD",
            "noRujukan": "string",
            "ppkRujukan": "string"
        }
    }
}
```

### 3. SEP (Surat Eligibilitas Peserta) Management
#### Endpoints
- Generate SEP (`/SEP/insert`)
- Update SEP (`/SEP/update`)
- Delete SEP (`/SEP/delete`)

#### Required Parameters for SEP Generation
```json
{
    "noKartu": "string",
    "tglSep": "YYYY-MM-DD",
    "tglRujukan": "YYYY-MM-DD",
    "noRujukan": "string",
    "ppkRujukan": "string",
    "jnsPelayanan": "string",
    "catatan": "string",
    "diagAwal": "string",
    "poliTujuan": "string",
    "user": "string",
    "noMr": "string"
}
```

### 4. Reference Data Lookups
#### Available Endpoints
- Healthcare Facilities (`/referensi/faskes`)
- Doctors (`/referensi/dokter`)
- Provinces (`/referensi/propinsi`)
- Specialists (`/referensi/spesialistik`)
- DPJP (Attending Doctors) (`/referensi/dpjp`)

#### Parameters for Reference Lookups
- Healthcare Facilities:
  ```json
  {
    "nama": "string",
    "jenis": "string",
    "start": "number",
    "limit": "number"
  }
  ```
- DPJP:
  ```json
  {
    "jenisPelayanan": "1|2", // 1=Inpatient, 2=Outpatient
    "tglPelayanan": "YYYY-MM-DD",
    "kodeSpesialis": "string"
  }
  ```

## Error Handling

The system implements the following error handling:
1. Service Unavailability (Code 502)
2. Invalid Data (Code 412)
3. Local Caching for Offline Operations
4. Fallback to Local Database

## Integration Requirements

### Authentication
- Requires BPJS API credentials
- Uses hospital code for request identification
- Implements secure token management

### Data Storage
Required tables for local caching:
1. `bpjs_peserta` - Patient data
2. `bpjs_rujukan` - Referral data
3. `bpjs_sep` - SEP data
4. `bpjs_dpjp` - Doctor reference data

### Configuration
Required configuration parameters:
```properties
bpjs.api.url=https://api.bpjs-kesehatan.go.id
bpjs.api.consid=your_consumer_id
bpjs.api.secret=your_secret_key
bpjs.hospital.code=your_hospital_code
```

## OpenMRS Implementation Considerations

### Required OpenMRS Modules
1. REST Web Services
2. ID Generation
3. Patient Registration
4. Appointment Scheduling

### Suggested Data Model Extensions
1. Patient
   - Add BPJS number field
   - Add NIK field
   - Add insurance class field

2. Visit
   - Add SEP number field
   - Add referral information
   - Add BPJS claim status

3. Provider
   - Add BPJS doctor code
   - Add specialization codes

### Integration Points
1. Patient Registration
   - Verify BPJS membership
   - Fetch patient demographics
   - Create/Update patient record

2. Visit Creation
   - Generate SEP
   - Validate referrals
   - Assign DPJP

3. Billing
   - INA-CBG integration
   - Claim submission
   - Verification status tracking

## Security Considerations

1. Data Protection
   - Encrypt sensitive data
   - Implement proper access controls
   - Log all BPJS transactions

2. API Security
   - Use HTTPS
   - Implement request signing
   - Handle token expiration

3. Compliance
   - Follow BPJS data retention policies
   - Implement audit trails
   - Handle consent management

## Testing Strategy

1. Unit Tests
   - Mock BPJS responses
   - Test error scenarios
   - Validate data transformations

2. Integration Tests
   - Test with BPJS test environment
   - Verify end-to-end workflows
   - Test offline scenarios

3. Performance Tests
   - Load testing for concurrent requests
   - Response time monitoring
   - Cache effectiveness

## Migration Steps

1. Database Setup
   ```sql
   CREATE TABLE bpjs_patient_mapping (
       patient_id INT,
       bpjs_number VARCHAR(13),
       nik VARCHAR(16),
       insurance_class VARCHAR(2),
       FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
   );

   CREATE TABLE bpjs_visit_data (
       visit_id INT,
       sep_number VARCHAR(20),
       referral_number VARCHAR(20),
       claim_status VARCHAR(10),
       FOREIGN KEY (visit_id) REFERENCES visit(visit_id)
   );
   ```

2. Module Development
   - Create REST endpoints
   - Implement service layer
   - Add UI components

3. Configuration
   - Set up BPJS credentials
   - Configure mappings
   - Set up logging

## Monitoring and Maintenance

1. Monitoring Points
   - API response times
   - Error rates
   - Cache hit rates
   - Sync status

2. Regular Maintenance
   - Update reference data
   - Clean up old cache
   - Verify credentials
   - Check logs

## Support and Troubleshooting

Common Issues and Solutions:
1. Connection Timeouts
   - Check network connectivity
   - Verify BPJS service status
   - Review proxy settings

2. Data Sync Issues
   - Verify local storage
   - Check last sync timestamp
   - Review error logs

3. Authentication Problems
   - Check credential validity
   - Verify system time
   - Review token lifecycle 