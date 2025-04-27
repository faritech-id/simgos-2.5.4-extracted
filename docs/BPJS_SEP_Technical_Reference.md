# BPJS and SEP Technical Reference

## Table of Contents
1. [Overview](#overview)
2. [API Configuration](#api-configuration)
3. [SEP Management](#sep-management)
4. [Authentication](#authentication)
5. [Error Handling](#error-handling)
6. [Integration Points](#integration-points)
7. [Data Structures](#data-structures)
8. [Service Modules](#service-modules)
9. [Implementation Guide](#implementation-guide)
10. [Security Considerations](#security-considerations)
11. [OpenMRS and ERPNext Integration](#openmrs-and-erpnext-integration)

## Overview

BPJS (Badan Penyelenggara Jaminan Sosial) is Indonesia's National Healthcare Insurance system. SEP (Surat Eligibilitas Peserta) is a core component that manages patient eligibility and healthcare service authorization.

## API Configuration

### Base URLs
```properties
# Production Environment
BPJS_API_PROD_URL=https://new-api.bpjs-kesehatan.go.id/new-vclaim-rest/

# Development Environment
BPJS_API_DEV_URL=https://dvlp.bpjs-kesehatan.go.id/vclaim-rest-dev/

# Demo Environment
BPJS_API_DEMO_URL=https://apijkn-dev.bpjs-kesehatan.go.id/vclaim-rest/
```

### Authentication URLs
```properties
# OAuth 2.0 Token Endpoint
BPJS_AUTH_URL=https://new-api.bpjs-kesehatan.go.id/new-vclaim-auth/
BPJS_AUTH_DEV_URL=https://dvlp.bpjs-kesehatan.go.id/vclaim-auth-dev/
```

### Required Headers
```json
{
    "X-Cons-ID": "{your-consumer-id}",
    "X-Timestamp": "YYYY-MM-DD HH:mm:ss",
    "X-Signature": "{hmac-signature}",
    "user_key": "{your-user-key}",
    "Content-Type": "application/json"
}
```

## SEP Management

### Core Endpoints

1. **SEP Generation**
   - Endpoint: `/SEP/insert`
   - Method: POST
   ```json
   // Request
   {
       "request": {
           "t_sep": {
               "noKartu": "string",
               "tglSep": "YYYY-MM-DD",
               "ppkPelayanan": "string",
               "jnsPelayanan": "1|2",
               "klsRawat": {
                   "klsRawatHak": "1|2|3"
               },
               "noMR": "string",
               "rujukan": {
                   "asalRujukan": "1|2",
                   "tglRujukan": "YYYY-MM-DD",
                   "noRujukan": "string",
                   "ppkRujukan": "string"
               },
               "catatan": "string",
               "diagAwal": "string",
               "poli": {
                   "tujuan": "string",
                   "eksekutif": "0|1"
               },
               "cob": {
                   "cob": "0|1"
               },
               "katarak": {
                   "katarak": "0|1"
               },
               "lakaLantas": "0|1|2|3",
               "penjamin": {
                   "penjamin": "1|2|3|4",
                   "tglKejadian": "YYYY-MM-DD",
                   "keterangan": "string",
                   "suplesi": {
                       "suplesi": "0|1",
                       "noSepSuplesi": "string",
                       "lokasiLaka": {
                           "kdPropinsi": "string",
                           "kdKabupaten": "string",
                           "kdKecamatan": "string"
                       }
                   }
               },
               "skdp": {
                   "noSurat": "string",
                   "kodeDPJP": "string"
               },
               "noTelp": "string",
               "user": "string"
           }
       }
   }

   // Response
   {
       "metadata": {
           "code": 200,
           "message": "OK"
       },
       "response": {
           "sep": {
               "noSep": "string",
               "tglSep": "YYYY-MM-DD",
               "peserta": {
                   "noKartu": "string",
                   "nama": "string",
                   "tglLahir": "YYYY-MM-DD",
                   "kelamin": "L|P"
               }
           }
       }
   }
   ```

2. **SEP Update**
   - Endpoint: `/SEP/update`
   - Method: PUT
   ```json
   // Request
   {
       "request": {
           "t_sep": {
               "noSep": "string",
               "klsRawat": {
                   "klsRawatHak": "1|2|3",
                   "klsRawatNaik": "1|2|3",
                   "pembiayaan": "1|2|3",
                   "penanggungJawab": "string"
               },
               "noMR": "string",
               "catatan": "string",
               "diagAwal": "string",
               "poli": {
                   "eksekutif": "0|1"
               },
               "cob": {
                   "cob": "0|1"
               },
               "katarak": {
                   "katarak": "0|1"
               },
               "skdp": {
                   "noSurat": "string",
                   "kodeDPJP": "string"
               },
               "dpjpLayan": "string",
               "noTelp": "string",
               "user": "string"
           }
       }
   }
   ```

3. **SEP Deletion**
   - Endpoint: `/SEP/delete`
   - Method: DELETE
   ```json
   // Request
   {
       "request": {
           "t_sep": {
               "noSep": "string",
               "user": "string"
           }
       }
   }
   ```

### Additional SEP Operations

1. **SEP Verification**
   - Endpoint: `/SEP/{noSEP}`
   - Method: GET

2. **SEP Application**
   - Submit: `/kunjungan/pengajuanSEP`
   - Approve: `/kunjungan/aprovalPengajuanSEP`
   - List: `/kunjungan/daftarPengajuan`
   - Cancel: `/kunjungan/batalPengajuanSEP`

3. **INA-CBG Integration**
   - Endpoint: `/sep/cbg/{noSEP}`
   - Method: GET

## Authentication

### Registration Process
1. Visit https://dvlp.bpjs-kesehatan.go.id/
2. Register healthcare facility
3. Request credentials (consumer ID and secret key)
4. Complete integration verification

### Token Management
```typescript
class BPJSAuthService {
    static async getToken(): Promise<string> {
        // Implementation
    }
    
    static async refreshToken(): Promise<string> {
        // Implementation
    }
}
```

## Error Handling

### Error Codes
- 200: Success
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 412: Invalid Data Format
- 500: Internal Server Error
- 502: Service Unavailable

### Error Response Format
```json
{
    "metadata": {
        "message": "Error Message",
        "code": "Error Code",
        "requestId": "hospital_code"
    }
}
```

## Integration Points

### 1. Patient Registration
- Verify BPJS membership
- Fetch patient demographics
- Create/Update patient record

### 2. Visit Creation
- Generate SEP
- Validate referrals
- Assign DPJP (Attending Doctor)

### 3. Billing Integration
- INA-CBG integration
- Claim submission
- Payment verification

## Data Structures

### 1. Patient Data
```json
{
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
```

### 2. SEP Data
```json
{
    "noSep": "string",
    "tglSep": "YYYY-MM-DD",
    "jnsPelayanan": "1|2", // 1=Inpatient, 2=Outpatient
    "kelasRawat": "string",
    "diagnosa": {
        "kode": "string",
        "nama": "string"
    },
    "poli": {
        "tujuan": "string",
        "eksekutif": "0|1"
    }
}
```

## Service Modules

1. **PesertaService**
   - Patient/Member verification
   - Eligibility checks

2. **SEPService**
   - SEP management
   - Hospital eligibility services

3. **ReferensiService**
   - Reference data services
   - Master data management

4. **RujukanService**
   - Referral management
   - Referral tracking

5. **MonitoringService**
   - Service monitoring
   - Performance tracking

## Implementation Guide

### 1. Database Setup
```sql
-- SEP Management
CREATE TABLE bpjs_sep (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sep_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    visit_id INT NOT NULL,
    bpjs_number VARCHAR(13) NOT NULL,
    service_type ENUM('1', '2') NOT NULL COMMENT '1=Inpatient, 2=Outpatient',
    class_type ENUM('1', '2', '3') NOT NULL,
    diagnosis_code VARCHAR(10),
    diagnosis_name VARCHAR(255),
    created_date DATETIME NOT NULL,
    created_by VARCHAR(50) NOT NULL,
    updated_date DATETIME,
    updated_by VARCHAR(50),
    status ENUM('active', 'inactive', 'cancelled') NOT NULL DEFAULT 'active',
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (visit_id) REFERENCES visits(id)
);

-- SEP History
CREATE TABLE bpjs_sep_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sep_id INT NOT NULL,
    action ENUM('create', 'update', 'cancel') NOT NULL,
    action_date DATETIME NOT NULL,
    action_by VARCHAR(50) NOT NULL,
    notes TEXT,
    FOREIGN KEY (sep_id) REFERENCES bpjs_sep(id)
);

-- Referral Management
CREATE TABLE bpjs_referrals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    referral_number VARCHAR(20) NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    bpjs_number VARCHAR(13) NOT NULL,
    source_facility_code VARCHAR(20) NOT NULL,
    destination_facility_code VARCHAR(20) NOT NULL,
    referral_date DATE NOT NULL,
    diagnosis_code VARCHAR(10),
    diagnosis_name VARCHAR(255),
    valid_until DATE NOT NULL,
    status ENUM('active', 'used', 'expired') NOT NULL DEFAULT 'active',
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);
```

### 2. Configuration Setup
```json
{
    "bpjs": {
        "apiUrl": "https://new-api.bpjs-kesehatan.go.id/new-vclaim-rest/",
        "consumerID": "your-consumer-id",
        "secretKey": "your-secret-key",
        "hospitalCode": "your-hospital-code"
    }
}
```

### 3. Service Implementation
```typescript
class BPJSService {
    static async lookupByBPJSNumber(bpjsNumber: string): Promise<BPJSResponse> {
        // Implementation
    }

    static async generateSEP(data: SEPRequest): Promise<SEPResponse> {
        // Implementation
    }

    static async updateSEP(data: SEPUpdateRequest): Promise<SEPResponse> {
        // Implementation
    }
}
```

## Security Considerations

### 1. Data Protection
- Encrypt sensitive data
- Implement access controls
- Maintain audit logs

### 2. API Security
- Use HTTPS
- Implement request signing
- Handle token expiration

### 3. Compliance
- Follow BPJS policies
- Implement consent management
- Maintain data privacy

## Support Resources

### Documentation
- Main Portal: https://dvlp.bpjs-kesehatan.go.id:8888/trust-mark/
- VClaim Docs: https://dvlp.bpjs-kesehatan.go.id/VClaim-Katalog/
- E-KATALOG: https://e-katalog.bpjs-kesehatan.go.id/

### Technical Support
- Email: vclaim@bpjs-kesehatan.go.id
- Support Portal: https://dvlp.bpjs-kesehatan.go.id/support
- Phone: (021) 424 6063 

## OpenMRS and ERPNext Integration

### 1. OpenMRS Integration

#### Module Structure
```
openmrs-module-bpjssep/
├── api/
│   ├── src/main/java/org/openmrs/module/bpjssep/
│   │   ├── BPJSSEPAPI.java
│   │   ├── BPJSSEPService.java
│   │   └── db/
│   │       └── hibernate/
│   │           └── HibernateBPJSSEPDAO.java
├── omod/
│   └── src/main/webapp/
│       └── resources/
│           └── js/
│               └── bpjssep.js
└── pom.xml
```

#### Java Service Layer
```java
public interface BPJSSEPService extends OpenmrsService {
    
    @Transactional
    SEP generateSEP(Patient patient, Visit visit, String bpjsNumber) throws APIException;
    
    @Transactional
    SEP updateSEP(String sepNumber, Map<String, Object> updateData) throws APIException;
    
    @Transactional
    boolean deleteSEP(String sepNumber) throws APIException;
    
    SEP getSEPDetails(String sepNumber) throws APIException;
}
```

#### PHP Bridge Service
```php
class OpenMRSBPJSBridge {
    private $bpjsService;
    private $openmrsAPI;
    
    public function __construct($config) {
        $this->bpjsService = new BPJSService($config['bpjs']);
        $this->openmrsAPI = new OpenMRSAPI($config['openmrs']);
    }
    
    public function generateSEPFromVisit($visitUuid) {
        // 1. Get visit details from OpenMRS
        $visit = $this->openmrsAPI->getVisit($visitUuid);
        $patient = $this->openmrsAPI->getPatient($visit['patient']['uuid']);
        
        // 2. Map OpenMRS data to BPJS format
        $bpjsRequest = $this->mapOpenMRSToBPJS($patient, $visit);
        
        // 3. Generate SEP through BPJS service
        $sepResponse = $this->bpjsService->generateSEP($bpjsRequest);
        
        // 4. Save SEP details back to OpenMRS
        $this->saveSEPToOpenMRS($sepResponse, $visitUuid);
        
        return $sepResponse;
    }
    
    private function mapOpenMRSToBPJS($patient, $visit) {
        return [
            "request" => [
                "t_sep" => [
                    "noKartu" => $patient['attributes']['bpjs_number'],
                    "tglSep" => date("Y-m-d"),
                    "ppkPelayanan" => FACILITY_CODE,
                    "jnsPelayanan" => $this->getServiceType($visit),
                    "klsRawat" => [
                        "klsRawatHak" => $patient['attributes']['insurance_class']
                    ],
                    "noMR" => $patient['identifiers']['medical_record_number'],
                    // ... map other required fields
                ]
            ]
        ];
    }
}
```

### 2. ERPNext Integration

#### Custom DocTypes
```json
{
    "doctype": "BPJS SEP",
    "fields": [
        {
            "fieldname": "sep_number",
            "label": "SEP Number",
            "fieldtype": "Data",
            "unique": 1
        },
        {
            "fieldname": "patient",
            "label": "Patient",
            "fieldtype": "Link",
            "options": "Patient"
        },
        {
            "fieldname": "visit",
            "label": "Patient Encounter",
            "fieldtype": "Link",
            "options": "Patient Encounter"
        },
        {
            "fieldname": "bpjs_number",
            "label": "BPJS Number",
            "fieldtype": "Data"
        },
        {
            "fieldname": "service_type",
            "label": "Service Type",
            "fieldtype": "Select",
            "options": "Inpatient\nOutpatient"
        }
    ]
}
```

#### Python Integration Class
```python
import frappe
from frappe import _
import requests
import json

class BPJSSEPIntegration:
    def __init__(self):
        self.settings = frappe.get_doc('BPJS Settings')
        self.php_bridge_url = self.settings.php_bridge_url
    
    def generate_sep(self, patient_encounter):
        patient = frappe.get_doc('Patient', patient_encounter.patient)
        
        # Prepare data for PHP bridge
        data = {
            'patient_data': {
                'bpjs_number': patient.bpjs_number,
                'medical_record': patient.medical_record_number
            },
            'encounter_data': {
                'type': patient_encounter.encounter_type,
                'date': patient_encounter.encounter_date
            }
        }
        
        # Call PHP bridge service
        response = requests.post(
            f"{self.php_bridge_url}/generate-sep",
            json=data,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            sep_data = response.json()
            
            # Create SEP document in ERPNext
            sep = frappe.get_doc({
                'doctype': 'BPJS SEP',
                'sep_number': sep_data['sep_number'],
                'patient': patient_encounter.patient,
                'visit': patient_encounter.name,
                'bpjs_number': patient.bpjs_number,
                'service_type': 'Outpatient' if patient_encounter.encounter_type == 'OPD' else 'Inpatient'
            })
            sep.insert()
            
            return sep
        else:
            frappe.throw(_('Failed to generate SEP'))
```

### 3. Integration Bridge Service

#### PHP Bridge API
```php
class IntegrationBridgeAPI {
    private $bpjsService;
    private $openmrsService;
    private $erpnextService;
    
    public function __construct($config) {
        $this->bpjsService = new BPJSService($config['bpjs']);
        $this->openmrsService = new OpenMRSBPJSBridge($config);
        $this->erpnextService = new ERPNextService($config['erpnext']);
    }
    
    public function handleSEPGeneration($data) {
        try {
            // 1. Generate SEP through OpenMRS bridge
            $sepResponse = $this->openmrsService->generateSEPFromVisit($data['visit_uuid']);
            
            // 2. Sync SEP data to ERPNext
            $this->erpnextService->createSEP([
                'sep_number' => $sepResponse['sep']['noSep'],
                'patient_id' => $data['patient_id'],
                'visit_id' => $data['visit_id'],
                'bpjs_data' => $sepResponse
            ]);
            
            return [
                'success' => true,
                'sep_data' => $sepResponse
            ];
            
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}
```

### 4. Data Flow Diagram
```
┌──────────────┐     ┌───────────────┐     ┌──────────────┐
│   OpenMRS    │     │   PHP Bridge  │     │    BPJS      │
│              │◄────►│    Service    │◄────►│    API      │
└──────────────┘     └───────┬───────┘     └──────────────┘
                             │
                             │
                     ┌───────▼───────┐
                     │   ERPNext     │
                     │              │
                     └──────────────┘
```

### 5. Implementation Steps

1. **Setup PHP Bridge Service**
   - Deploy the PHP bridge service on your server
   - Configure connection settings for all systems
   - Set up error logging and monitoring

2. **Install OpenMRS Module**
   - Install the BPJS-SEP module in OpenMRS
   - Configure module settings
   - Set up required patient attributes

3. **Install ERPNext Customizations**
   - Install custom DocTypes
   - Configure BPJS settings
   - Set up API authentication

4. **Testing and Verification**
   - Test SEP generation flow
   - Verify data synchronization
   - Test error handling

### 6. Security Considerations

1. **API Security**
   - Use HTTPS for all communications
   - Implement API authentication
   - Validate all requests

2. **Data Protection**
   - Encrypt sensitive data
   - Implement audit logging
   - Follow BPJS security guidelines

3. **Error Handling**
   - Implement comprehensive error logging
   - Set up monitoring alerts
   - Create fallback procedures

[Rest of the document remains unchanged...] 