# OpenMRS SEP Integration Guide (Without Custom Module)

## Overview

This guide describes how to integrate BPJS SEP functionality into OpenMRS using existing core features and REST APIs, without creating a custom module.

## Integration Approach

### 1. Patient Attributes

Add BPJS-related attributes to OpenMRS patient data using Person Attributes:

```sql
-- Add Person Attribute Types for BPJS
INSERT INTO person_attribute_type 
(name, description, format, searchable, creator, date_created, uuid)
VALUES 
('BPJS Number', 'BPJS Insurance Number', 'java.lang.String', 1, 1, NOW(), UUID()),
('SEP Number', 'BPJS SEP Reference Number', 'java.lang.String', 1, 1, NOW(), UUID()),
('Insurance Class', 'BPJS Insurance Class', 'java.lang.String', 1, 1, NOW(), UUID());
```

### 2. Visit Attributes

Store SEP-related data using Visit Attributes:

```sql
-- Add Visit Attribute Types for SEP
INSERT INTO visit_attribute_type
(name, description, datatype, min_occurs, creator, date_created, uuid)
VALUES
('SEP Details', 'BPJS SEP Information', 'org.openmrs.customdatatype.datatype.FreeTextDatatype', 0, 1, NOW(), UUID()),
('Referral Number', 'BPJS Referral Number', 'org.openmrs.customdatatype.datatype.FreeTextDatatype', 0, 1, NOW(), UUID());
```

### 3. REST API Integration

Create a proxy service to handle BPJS-SEP API calls:

```javascript
// bpjs-proxy.js
const express = require('express');
const axios = require('axios');
const router = express.Router();

// BPJS API Configuration
const BPJS_CONFIG = {
  baseURL: process.env.BPJS_API_URL,
  headers: {
    'X-Cons-ID': process.env.BPJS_CONS_ID,
    'X-Timestamp': new Date().toISOString(),
    'Content-Type': 'application/json'
  }
};

// Proxy SEP Generation
router.post('/sep/create', async (req, res) => {
  try {
    // Get patient data from OpenMRS
    const patientData = await axios.get(
      `${OPENMRS_API_URL}/patient/${req.body.patientUuid}`,
      { headers: { Authorization: req.headers.authorization } }
    );

    // Generate SEP through BPJS API
    const sepResponse = await axios.post(
      `${BPJS_CONFIG.baseURL}/SEP/insert`,
      mapToSEPRequest(patientData.data, req.body),
      { headers: BPJS_CONFIG.headers }
    );

    // Save SEP data back to OpenMRS
    await saveSEPToOpenMRS(req.body.visitUuid, sepResponse.data);

    res.json(sepResponse.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Helper function to map OpenMRS data to SEP request
function mapToSEPRequest(patient, visitData) {
  return {
    request: {
      t_sep: {
        noKartu: patient.attributes.find(a => a.display.startsWith('BPJS Number')).value,
        tglSep: new Date().toISOString().split('T')[0],
        ppkPelayanan: process.env.HOSPITAL_CODE,
        jnsPelayanan: visitData.visitType === 'INPATIENT' ? '1' : '2',
        klsRawat: {
          klsRawatHak: patient.attributes.find(a => a.display.startsWith('Insurance Class')).value
        },
        noMR: patient.identifiers[0].identifier,
        // ... map other required fields
      }
    }
  };
}

// Helper function to save SEP data to OpenMRS
async function saveSEPToOpenMRS(visitUuid, sepData) {
  const visitAttribute = {
    attributeType: 'SEP Details',
    value: JSON.stringify(sepData)
  };

  await axios.post(
    `${OPENMRS_API_URL}/visit/${visitUuid}/attribute`,
    visitAttribute,
    { headers: { Authorization: req.headers.authorization } }
  );
}
```

### 4. HTML Form Integration

Create an HTML Form to capture SEP data within OpenMRS:

```html
<!-- sep-form.html -->
<htmlform>
    <h2>SEP Generation Form</h2>
    
    <section>
        <h3>Patient BPJS Information</h3>
        <p>
            <label>BPJS Number:</label>
            <lookup complexExpression="personAttribute('BPJS Number')"/>
        </p>
        <p>
            <label>Insurance Class:</label>
            <lookup complexExpression="personAttribute('Insurance Class')"/>
        </p>
    </section>
    
    <section>
        <h3>Referral Information</h3>
        <p>
            <label>Referral Number:</label>
            <obs conceptId="162876"/>
        </p>
        <p>
            <label>Referral Type:</label>
            <obs conceptId="162877" 
                 answerConceptIds="162878,162879"
                 answerLabels="Internal,External"/>
        </p>
    </section>
    
    <button onclick="generateSEP()">Generate SEP</button>
    
    <script>
        function generateSEP() {
            const visitUuid = getVisitUuid();
            const patientUuid = getPatientUuid();
            
            fetch('/bpjs-proxy/sep/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Basic ' + window.sessionStorage.getItem('basicAuth')
                },
                body: JSON.stringify({
                    patientUuid,
                    visitUuid,
                    visitType: getVisitType(),
                    referralNumber: getValue('obs.162876'),
                    referralType: getValue('obs.162877')
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.metadata.code === 200) {
                    displayMessage('SEP generated successfully: ' + data.response.sep.noSep);
                } else {
                    displayError('Failed to generate SEP: ' + data.metadata.message);
                }
            })
            .catch(error => displayError('Error: ' + error.message));
        }
    </script>
</htmlform>
```

### 5. Global Properties

Add necessary configuration in OpenMRS settings:

```sql
-- Add Global Properties for BPJS Integration
INSERT INTO global_property (property, property_value, description, uuid)
VALUES
('bpjs.api.url', 'https://api.bpjs-kesehatan.go.id', 'BPJS API Base URL', UUID()),
('bpjs.cons.id', 'your-consumer-id', 'BPJS Consumer ID', UUID()),
('bpjs.secret.key', 'your-secret-key', 'BPJS Secret Key', UUID()),
('bpjs.user.key', 'your-user-key', 'BPJS User Key', UUID()),
('hospital.code', 'your-hospital-code', 'Hospital Code for BPJS', UUID());
```

### 6. Encounter Types and Concepts

Add necessary metadata for SEP documentation:

```sql
-- Add Encounter Type for SEP
INSERT INTO encounter_type (name, description, creator, date_created, uuid)
VALUES ('SEP Generation', 'BPJS SEP Generation Encounter', 1, NOW(), UUID());

-- Add Concepts for SEP Documentation
INSERT INTO concept (datatype_id, class_id, is_set, creator, date_created, uuid)
VALUES 
(4, 11, 0, 1, NOW(), UUID()), -- SEP Number
(4, 11, 0, 1, NOW(), UUID()), -- Referral Number
(4, 11, 0, 1, NOW(), UUID()); -- SEP Status
```

## Implementation Steps

1. **Database Setup**
   - Execute SQL scripts for Person Attributes
   - Execute SQL scripts for Visit Attributes
   - Add necessary Concepts and Encounter Types
   - Configure Global Properties

2. **Proxy Service Setup**
   ```bash
   # Install dependencies
   npm init -y
   npm install express axios cors dotenv

   # Start proxy service
   node bpjs-proxy.js
   ```

3. **HTML Form Configuration**
   - Add HTML Form to OpenMRS
   - Configure form privileges
   - Add form to appropriate visit workflows

4. **Testing**
   - Test BPJS number validation
   - Test SEP generation
   - Verify data storage in OpenMRS
   - Test error handling

## Security Considerations

1. **Authentication**
   - Use OpenMRS role-based access control
   - Secure BPJS API credentials
   - Implement request signing

2. **Data Protection**
   - Encrypt sensitive data
   - Implement audit logging
   - Secure communication channels

3. **Error Handling**
   - Validate input data
   - Handle API timeouts
   - Implement retry mechanisms

## Usage Example

1. **Patient Registration**
   ```javascript
   // Add BPJS Number during registration
   fetch('/openmrs/ws/rest/v1/person/' + patientUuid + '/attribute', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify({
       attributeType: 'BPJS Number',
       value: bpjsNumber
     })
   });
   ```

2. **SEP Generation**
   ```javascript
   // Generate SEP during visit
   fetch('/bpjs-proxy/sep/create', {
     method: 'POST',
     headers: { 'Content-Type': 'application/json' },
     body: JSON.stringify({
       patientUuid: patient.uuid,
       visitUuid: visit.uuid,
       visitType: visit.visitType
     })
   });
   ```

3. **SEP Verification**
   ```javascript
   // Verify SEP status
   fetch('/bpjs-proxy/sep/' + sepNumber, {
     method: 'GET',
     headers: { 'Content-Type': 'application/json' }
   });
   ``` 