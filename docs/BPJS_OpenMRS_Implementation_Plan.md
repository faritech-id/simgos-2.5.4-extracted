# BPJS Integration Implementation Plan for OpenMRS

## 1. Configuration Module
```typescript
// File: src/config/bpjs-config.ts
export interface BPJSConfig {
  apiBaseUrl: string;
  consumerID: string;
  secretKey: string;
  userKey: string;
  hospitalCode: string;
}

// Add to config-schema.ts
export const configSchema = {
  bpjsIntegration: {
    apiBaseUrl: {
      _type: Type.String,
      _default: 'https://new-api.bpjs-kesehatan.go.id/new-vclaim-rest/',
      _description: 'BPJS API Base URL'
    },
    consumerID: {
      _type: Type.String,
      _default: '',
      _description: 'BPJS Consumer ID'
    },
    secretKey: {
      _type: Type.String,
      _default: '',
      _description: 'BPJS Secret Key'
    }
  }
};
```

## 2. BPJS Service Layer
```typescript
// File: src/patient-registration/services/bpjs.service.ts
import { openmrsFetch, useConfig } from '@openmrs/esm-framework';

export interface BPJSResponse {
  metadata: {
    message: string;
    code: number;
    requestId: string;
  };
  response: {
    peserta: BPJSPatient;
  };
}

export interface BPJSPatient {
  noKartu: string;
  nik: string;
  nama: string;
  sex: string;
  tglLahir: string;
  // ... other BPJS fields
}

export class BPJSService {
  static async lookupByBPJSNumber(bpjsNumber: string): Promise<BPJSResponse> {
    const config = useConfig();
    const headers = this.generateHeaders();
    
    const response = await openmrsFetch(`${config.bpjsIntegration.apiBaseUrl}/Peserta/nokartu/${bpjsNumber}`, {
      headers,
      method: 'GET'
    });
    
    return response.data;
  }

  static async lookupByNIK(nik: string): Promise<BPJSResponse> {
    const config = useConfig();
    const headers = this.generateHeaders();
    
    const response = await openmrsFetch(`${config.bpjsIntegration.apiBaseUrl}/Peserta/nik/${nik}`, {
      headers,
      method: 'GET'
    });
    
    return response.data;
  }

  private static generateHeaders() {
    const timestamp = new Date().toISOString();
    const signature = this.generateSignature(timestamp);
    
    return {
      'X-Cons-ID': config.bpjsIntegration.consumerID,
      'X-Timestamp': timestamp,
      'X-Signature': signature,
      'Content-Type': 'application/json'
    };
  }
}
```

## 3. Data Mapping Layer
```typescript
// File: src/patient-registration/mappings/bpjs-mapper.ts
export interface OpenMRSPatient {
  identifiers: Array<{
    identifier: string;
    identifierType: string;
  }>;
  person: {
    names: Array<{
      givenName: string;
      familyName: string;
    }>;
    gender: string;
    birthdate: string;
    // ... other OpenMRS fields
  };
}

export class BPJSMapper {
  static mapToOpenMRSPatient(bpjsData: BPJSPatient): OpenMRSPatient {
    return {
      identifiers: [
        {
          identifier: bpjsData.noKartu,
          identifierType: 'BPJS_NUMBER'
        },
        {
          identifier: bpjsData.nik,
          identifierType: 'NIK'
        }
      ],
      person: {
        names: [{
          givenName: bpjsData.nama.split(' ')[0],
          familyName: bpjsData.nama.split(' ').slice(1).join(' ')
        }],
        gender: bpjsData.sex === 'L' ? 'M' : 'F',
        birthdate: bpjsData.tglLahir
      }
    };
  }
}
```

## 4. UI Components
```typescript
// File: src/patient-registration/input/custom-input/bpjs-lookup.component.tsx
import React from 'react';
import { useTranslation } from 'react-i18next';
import { Button, TextInput, InlineLoading } from '@carbon/react';

interface BPJSLookupProps {
  onPatientFound: (patient: OpenMRSPatient) => void;
}

export const BPJSLookup: React.FC<BPJSLookupProps> = ({ onPatientFound }) => {
  const { t } = useTranslation();
  const [identifier, setIdentifier] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLookup = async () => {
    setLoading(true);
    setError('');
    try {
      const response = await BPJSService.lookupByBPJSNumber(identifier);
      if (response.metadata.code === 200) {
        const mappedPatient = BPJSMapper.mapToOpenMRSPatient(response.response.peserta);
        onPatientFound(mappedPatient);
      } else {
        setError(response.metadata.message);
      }
    } catch (err) {
      setError(t('bpjsLookupError'));
    }
    setLoading(false);
  };

  return (
    <div className="bpjs-lookup">
      <TextInput
        id="bpjs-number"
        labelText={t('bpjsNumber')}
        value={identifier}
        onChange={(e) => setIdentifier(e.target.value)}
      />
      <Button onClick={handleLookup} disabled={loading}>
        {loading ? <InlineLoading /> : t('lookup')}
      </Button>
      {error && <div className="error">{error}</div>}
    </div>
  );
};
```

## 5. Integration Points
```typescript
// File: src/patient-registration/patient-registration.component.tsx
import { BPJSLookup } from './input/custom-input/bpjs-lookup.component';

export const PatientRegistration: React.FC = () => {
  const handleBPJSPatientFound = (patient: OpenMRSPatient) => {
    // Pre-fill form with patient data
    setFormData((prev) => ({
      ...prev,
      identifiers: [...prev.identifiers, ...patient.identifiers],
      givenName: patient.person.names[0].givenName,
      familyName: patient.person.names[0].familyName,
      gender: patient.person.gender,
      birthdate: patient.person.birthdate
    }));
  };

  return (
    <div>
      <BPJSLookup onPatientFound={handleBPJSPatientFound} />
      {/* Existing registration form */}
    </div>
  );
};
```

## 6. Error Handling
```typescript
// File: src/patient-registration/error/bpjs-error-handler.ts
export class BPJSErrorHandler {
  static handleError(error: any): string {
    if (error.metadata) {
      switch (error.metadata.code) {
        case 412:
          return 'Invalid BPJS number format';
        case 502:
          return 'BPJS service unavailable';
        case 404:
          return 'Patient not found in BPJS';
        default:
          return `BPJS Error: ${error.metadata.message}`;
      }
    }
    return 'Unknown error occurred';
  }
}
```

## 7. Translations
```json
// File: translations/en.json
{
  "bpjsNumber": "BPJS Number",
  "lookup": "Look up",
  "bpjsLookupError": "Error looking up BPJS data",
  "patientFoundInBPJS": "Patient found in BPJS",
  "invalidBPJSNumber": "Invalid BPJS number",
  "bpjsServiceUnavailable": "BPJS service is currently unavailable"
}
```

## 8. Implementation Steps

1. Configuration Setup:
   ```bash
   # Add BPJS configuration to OpenMRS
   POST /ws/rest/v1/systemsetting
   {
     "property": "bpjs.config",
     "value": {
       "apiBaseUrl": "https://new-api.bpjs-kesehatan.go.id/new-vclaim-rest/",
       "consumerID": "your-consumer-id",
       "secretKey": "your-secret-key"
     }
   }
   ```

2. Database Updates:
   ```sql
   -- Add BPJS identifier type
   INSERT INTO patient_identifier_type 
   (name, description, format, validator)
   VALUES 
   ('BPJS Number', 'BPJS Insurance Number', '^\\d{13}$', 'org.openmrs.patient.impl.LuhnIdentifierValidator');
   ```

3. Module Installation:
   ```bash
   # Install dependencies
   npm install --save @carbon/react @openmrs/esm-framework
   ```

4. Testing:
   ```typescript
   // File: src/patient-registration/bpjs-lookup.test.tsx
   describe('BPJS Lookup', () => {
     it('should handle successful BPJS lookup', async () => {
       // Test implementation
     });
     
     it('should handle BPJS service errors', async () => {
       // Test implementation
     });
   });
   ```

## 9. Security Considerations

1. Token Management:
```typescript
// File: src/patient-registration/services/bpjs-auth.service.ts
export class BPJSAuthService {
  static async getToken(): Promise<string> {
    // Implementation for token management
  }
  
  static async refreshToken(): Promise<string> {
    // Implementation for token refresh
  }
}
```

2. Data Protection:
```typescript
// File: src/patient-registration/services/bpjs-encryption.service.ts
export class BPJSEncryptionService {
  static encryptRequest(data: any): string {
    // Implementation for request encryption
  }
  
  static decryptResponse(data: string): any {
    // Implementation for response decryption
  }
}
```

## 10. Monitoring and Logging
```typescript
// File: src/patient-registration/services/bpjs-monitoring.service.ts
export class BPJSMonitoringService {
  static logLookup(identifier: string, success: boolean, error?: string): void {
    // Implementation for logging BPJS lookups
  }
  
  static async getStats(): Promise<BPJSStats> {
    // Implementation for getting usage statistics
  }
}
``` 