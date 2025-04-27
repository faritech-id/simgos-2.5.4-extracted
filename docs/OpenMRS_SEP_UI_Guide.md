# OpenMRS SEP UI Integration Guide

## Overview

This guide details how to modify the OpenMRS UI to incorporate SEP generation functionality using OpenMRS's native features.

## UI Integration Points

### 1. Patient Dashboard Modifications

```html
<!-- patient-dashboard-sep.html -->
<div id="sep-dashboard" class="info-section">
    <div class="info-header">
        <i class="icon-medical"></i>
        <h3>BPJS SEP Information</h3>
        <a href="sep-form.page?patientId={{patientId}}" class="right">
            <i class="icon-pencil"></i> Generate SEP
        </a>
    </div>
    <div class="info-body">
        <div>
            <label>BPJS Number:</label>
            <span>{{bpjsNumber}}</span>
        </div>
        <div>
            <label>Active SEP:</label>
            <span>{{activeSepNumber}}</span>
            <span class="status-{{sepStatus}}">{{sepStatus}}</span>
        </div>
        <div>
            <label>Insurance Class:</label>
            <span>{{insuranceClass}}</span>
        </div>
    </div>
</div>
```

### 2. Visit Dashboard Integration

```html
<!-- visit-dashboard-sep.html -->
<div class="visit-actions">
    <h4>Visit Actions</h4>
    <div class="action-section">
        <button id="generate-sep" 
                class="confirm" 
                onclick="openSEPDialog()">
            Generate SEP
        </button>
    </div>
</div>

<div id="sep-dialog" class="dialog" style="display: none;">
    <div class="dialog-header">
        <h3>Generate SEP</h3>
    </div>
    <div class="dialog-content">
        <form id="sep-form">
            <p>
                <label>Visit Type:</label>
                <select name="visitType" required>
                    <option value="1">Rawat Inap</option>
                    <option value="2">Rawat Jalan</option>
                </select>
            </p>
            <p>
                <label>Referral Number:</label>
                <input type="text" name="referralNumber" required/>
            </p>
            <p>
                <label>Diagnosis:</label>
                <input type="text" name="diagnosis" required/>
            </p>
            <button type="submit" class="confirm">Generate</button>
            <button type="button" class="cancel" onclick="closeSEPDialog()">Cancel</button>
        </form>
    </div>
</div>
```

### 3. SEP Generation Form

```html
<!-- sep-generation-form.html -->
<htmlform>
    <style>
        .sep-form {
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background: #fff;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .sep-section {
            margin-bottom: 20px;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .sep-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        .sep-actions {
            margin-top: 20px;
            text-align: right;
        }
        .status-indicator {
            padding: 4px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-success { background: #e6ffe6; color: #006600; }
        .status-error { background: #ffe6e6; color: #cc0000; }
    </style>

    <div class="sep-form">
        <h2>SEP Generation</h2>
        
        <!-- Patient Information -->
        <div class="sep-section">
            <h3>Patient Information</h3>
            <div class="sep-grid">
                <p>
                    <label>Name:</label>
                    <lookup expression="patient.personName"/>
                </p>
                <p>
                    <label>BPJS Number:</label>
                    <lookup complexExpression="personAttribute('BPJS Number')"/>
                </p>
                <p>
                    <label>Medical Record:</label>
                    <lookup expression="patient.patientIdentifier.identifier"/>
                </p>
                <p>
                    <label>Insurance Class:</label>
                    <lookup complexExpression="personAttribute('Insurance Class')"/>
                </p>
            </div>
        </div>

        <!-- Visit Information -->
        <div class="sep-section">
            <h3>Visit Information</h3>
            <div class="sep-grid">
                <p>
                    <label>Visit Type:</label>
                    <obs conceptId="160540" 
                         answerConceptIds="160544,160543"
                         answerLabels="Outpatient,Inpatient"
                         style="radio"/>
                </p>
                <p>
                    <label>Department:</label>
                    <obs conceptId="160541" />
                </p>
            </div>
        </div>

        <!-- Referral Information -->
        <div class="sep-section">
            <h3>Referral Information</h3>
            <div class="sep-grid">
                <p>
                    <label>Referral Number:</label>
                    <obs conceptId="162876" required="true"/>
                </p>
                <p>
                    <label>Referral Type:</label>
                    <obs conceptId="162877" 
                         answerConceptIds="162878,162879"
                         answerLabels="Internal,External"
                         style="radio"/>
                </p>
                <p>
                    <label>Referral Source:</label>
                    <obs conceptId="162880"/>
                </p>
                <p>
                    <label>Referral Date:</label>
                    <obs conceptId="162881" />
                </p>
            </div>
        </div>

        <!-- Diagnosis Information -->
        <div class="sep-section">
            <h3>Diagnosis Information</h3>
            <div class="sep-grid">
                <p>
                    <label>Primary Diagnosis:</label>
                    <obs conceptId="162882" required="true"/>
                </p>
                <p>
                    <label>Secondary Diagnosis:</label>
                    <obs conceptId="162883"/>
                </p>
            </div>
        </div>

        <!-- Actions -->
        <div class="sep-actions">
            <button type="button" class="cancel" onclick="cancelSEP()">Cancel</button>
            <button type="button" class="confirm" onclick="generateSEP()">Generate SEP</button>
        </div>
    </div>

    <script>
        function generateSEP() {
            const data = {
                patientUuid: patient.uuid,
                visitType: getValue('obs.160540'),
                referralNumber: getValue('obs.162876'),
                referralType: getValue('obs.162877'),
                diagnosis: getValue('obs.162882'),
                department: getValue('obs.160541')
            };

            jq.ajax({
                url: '/bpjs-proxy/sep/create',
                method: 'POST',
                data: JSON.stringify(data),
                contentType: 'application/json',
                success: function(response) {
                    if (response.metadata.code === 200) {
                        showToast('SEP generated successfully: ' + response.response.sep.noSep);
                        // Save SEP number to patient attributes
                        saveSEPNumber(response.response.sep.noSep);
                    } else {
                        showToast('Failed to generate SEP: ' + response.metadata.message, 'error');
                    }
                },
                error: function(xhr) {
                    showToast('Error generating SEP: ' + xhr.responseText, 'error');
                }
            });
        }

        function saveSEPNumber(sepNumber) {
            const data = {
                attributeType: 'SEP Number',
                value: sepNumber
            };

            jq.ajax({
                url: '/openmrs/ws/rest/v1/person/' + patient.uuid + '/attribute',
                method: 'POST',
                data: JSON.stringify(data),
                contentType: 'application/json',
                success: function() {
                    window.location.reload();
                }
            });
        }

        function cancelSEP() {
            window.history.back();
        }
    </script>
</htmlform>
```

### 4. Custom CSS Styles

```css
/* sep-styles.css */
.sep-info {
    background: #f9f9f9;
    border: 1px solid #ddd;
    padding: 10px;
    margin: 10px 0;
    border-radius: 4px;
}

.sep-status {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 3px;
    font-size: 12px;
    font-weight: bold;
}

.sep-status-active {
    background: #e6ffe6;
    color: #006600;
}

.sep-status-inactive {
    background: #ffe6e6;
    color: #cc0000;
}

.sep-button {
    background: #1e4bd1;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
}

.sep-button:hover {
    background: #1a3dad;
}
```

## Integration Steps

1. **Add UI Elements to Patient Dashboard**
   ```javascript
   // patient-dashboard.js
   function addSEPSection() {
       const sepSection = document.createElement('div');
       sepSection.innerHTML = getSEPTemplate();
       document.querySelector('#patient-dashboard').appendChild(sepSection);
   }
   ```

2. **Configure Visit Actions**
   ```javascript
   // visit-actions.js
   function initializeSEPActions() {
       if (hasActiveSEP()) {
           showSEPStatus();
       } else {
           showSEPGenerationButton();
       }
   }
   ```

3. **Add Form to Visit Workflow**
   ```javascript
   // visit-workflow.js
   function addSEPFormToWorkflow() {
       const workflow = getActiveWorkflow();
       workflow.addForm('SEP Generation', 'sep-generation-form.html');
   }
   ```

## Usage Instructions

1. **Patient Registration**
   - Enter BPJS Number during registration
   - System validates BPJS membership
   - Stores insurance class information

2. **Visit Creation**
   - Select visit type
   - System checks SEP requirements
   - Option to generate SEP appears

3. **SEP Generation**
   - Click "Generate SEP" button
   - Fill required information
   - System generates and stores SEP

4. **SEP Management**
   - View active SEPs
   - Check SEP status
   - Update or cancel SEP

## Customization Options

1. **Form Layout**
   - Modify HTML form structure
   - Customize CSS styles
   - Add/remove fields

2. **Workflow Integration**
   - Adjust when SEP generation is available
   - Modify validation rules
   - Change form sequence

3. **UI Components**
   - Customize buttons and icons
   - Modify status indicators
   - Add new sections

## Error Handling

1. **Form Validation**
   ```javascript
   function validateSEPForm() {
       const required = ['visitType', 'referralNumber', 'diagnosis'];
       let isValid = true;
       
       required.forEach(field => {
           if (!getValue(`obs.${field}`)) {
               showError(`${field} is required`);
               isValid = false;
           }
       });
       
       return isValid;
   }
   ```

2. **API Error Handling**
   ```javascript
   function handleSEPError(error) {
       if (error.response) {
           showToast(error.response.data.message, 'error');
       } else {
           showToast('Network error occurred', 'error');
       }
   }
   ```

## Security Considerations

1. **Access Control**
   - Configure required privileges
   - Implement role-based access
   - Audit form access

2. **Data Validation**
   - Validate BPJS numbers
   - Check referral validity
   - Verify visit eligibility 