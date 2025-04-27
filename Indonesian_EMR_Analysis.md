# Indonesian EMR System Analysis

## Executive Summary

This document provides a comprehensive analysis of the existing Indonesian Electronic Medical Record (EMR) system to inform the implementation of a localized version of the CARE healthcare system for Indonesia. The analysis covers patient data structures, healthcare provider information, clinical data models, insurance and billing processes, regulatory compliance, user interface patterns, and integration points with external systems.

## 1. Patient Data Structure

### 1.1 Patient Identifiers

The Indonesian EMR system uses several key identifiers for patients:

- **NORM (Nomor Rekam Medis)**: The primary medical record number used internally
- **NIK (Nomor Induk Kependudukan)**: The national ID number (16 digits)
- **BPJS Number (No Kartu)**: The national health insurance card number
- **NO_KK (Nomor Kartu Keluarga)**: Family card number
- **NOMOR**: Generic identifier field used in various contexts

Example from patient entity:
```sql
CREATE TABLE IF NOT EXISTS `pasien` (
  `NORM` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Nomor Rekam Medis',
  `NAMA` varchar(75) NOT NULL,
  `PANGGILAN` varchar(15) DEFAULT NULL COMMENT 'Nama Panggilan',
  `GELAR_DEPAN` varchar(25) DEFAULT NULL,
  `GELAR_BELAKANG` varchar(35) DEFAULT NULL,
  `TEMPAT_LAHIR` varchar(35) DEFAULT NULL,
  `TANGGAL_LAHIR` datetime NOT NULL,
  `JENIS_KELAMIN` tinyint(4) NOT NULL DEFAULT '1',
  ...
```

### 1.2 Required Demographic Fields

The following demographic fields are required by Indonesian regulations:

- Full name (with optional titles/honorifics)
- Date of birth
- Place of birth
- Gender
- Address (including RT/RW - neighborhood/community identifiers)
- Religion
- Education level
- Occupation
- Blood type
- Marital status

### 1.3 Patient Relationships and Family Information

Family information is tracked through:

- Family card number (NO_KK)
- Family relationship status (STAT_HBKEL)
- Parent information (NAMA_LGKP_IBU, NAMA_LGKP_AYAH)

The system integrates with Dukcapil (Population and Civil Registration) to verify family relationships:

```php
// DukcapilService integration for family data
$founds = $this->keluarga->load(["NO_KK" => $content["NO_KK"]]);
$keluarga = $this->keluarga->simpanData($content, count($founds) == 0);
                    
$founds = $this->penduduk->load(["NIK" => $content["NIK"]]);
$penduduk = $this->penduduk->simpanData($content, count($founds) == 0);
```

### 1.4 Indonesia-specific Patient Categorizations

The system includes several Indonesia-specific patient categorizations:

- BPJS insurance class (kdKelas/nmKelas)
- Insurance status (pisa)
- Patient type for reporting (jenis_pasien)
- Special categories for TB patients, COVID-19 patients

## 2. Healthcare Provider Information

### 2.1 Healthcare Facility Categorization

Healthcare facilities (PPK - Pemberi Pelayanan Kesehatan) are categorized as follows:

```sql
CREATE TABLE IF NOT EXISTS `ppk` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KODE` char(10) DEFAULT NULL COMMENT 'Kode Kemenkes',
  `BPJS` char(8) DEFAULT NULL COMMENT 'Kode BPJS',
  `JENIS` tinyint(4) DEFAULT NULL COMMENT 'Jenis PPK',
  `KEPEMILIKAN` tinyint(4) DEFAULT NULL COMMENT 'Kepemilikan',
  `JPK` tinyint(4) DEFAULT NULL COMMENT 'Tipe / Jenis Pelayanan Kesehatan',
  `NAMA` varchar(75) NOT NULL,
  `KELAS` char(1) NOT NULL,
  ...
```

The system automatically categorizes facilities based on naming patterns:
- Rumah Sakit (RS, RSU, RSK) - Hospitals
- Puskesmas - Community Health Centers
- Klinik - Clinics
- Individual doctors (dr., drg.)

### 2.2 Provider Credentials and Identifiers

Provider credentials include:
- NIP (Nomor Induk Pegawai) - Employee ID
- SIP (Surat Izin Praktek) - Practice license
- Specialization codes
- BPJS doctor codes for insurance claims

### 2.3 Provider Roles and Permissions

The system implements role-based access control:
- PPA (Pemberi Pelayanan Asuhan) - Care providers
- Administrative staff
- Specialized roles for specific modules

Example permission check:
```php
protected function onAfterAuthenticated($params = []) {
    $event = $params["event"];
    if($event->getName() == "create" || $event->getName() == "update") {
        $ppa = $this->pengguna
            ->getPegawaiService()
            ->isPPA($this->dataAkses->NIP);
        if(!$ppa) return new ApiProblem(405, 'Anda tidak memiliki akses untuk melakukan penginputan / perubahan '.$this->title);
    }
}
```

## 3. Clinical Data Models

### 3.1 Medical Coding Systems

The system uses several medical coding systems:
- ICD-10 for diagnoses
- ICD-9-CM for procedures
- Custom codes for TB, COVID-19, and other specific conditions

```php
// ICD-10 entity
class ICD10Entity extends SystemArrayObject
{
    protected $fields = [
        'ID'=>1
        , 'NOPEN'=>1
        , 'KODE'=>1
        , 'DIAGNOSA'=>1
        , 'UTAMA'=>1
        , 'INACBG'=>1
        , 'BARU'=>1
        , 'TANGGAL'=>1
        , 'OLEH'=>1
        , 'STATUS'=>1
        , 'INA_GROUPER'=>1
    ];
}
```

### 3.2 Diagnoses, Procedures, and Medications Structure

Diagnoses are structured with:
- ICD-10 code
- Description
- Primary/secondary flag (UTAMA)
- New case flag (BARU)
- INA-CBG grouping flag

Procedures use:
- ICD-9-CM code
- Description
- INA-CBG grouping flag

Medications are structured with:
- Medication code
- Dosage
- Duration
- Administration route
- FHIR-compatible fields for interoperability

### 3.3 Indonesia-specific Clinical Workflows

The system includes specialized clinical workflows for:
- TB management (SITB integration)
- COVID-19 reporting
- Maternal and child health
- Specialized assessment forms (CAT/CLAMS, ABCI)

### 3.4 Vital Signs and Observations

Vital signs are recorded in standardized formats:
```sql
CREATE TABLE IF NOT EXISTS `nutrisi` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `BERAT_BADAN` decimal(10,2) NOT NULL,
  `TINGGI_BADAN` decimal(10,2) NOT NULL,
  `INDEX_MASSA_TUBUH` decimal(10,2) NOT NULL,
  `LINGKAR_KEPALA` decimal(10,2) NOT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` int(11) NOT NULL,
  `STATUS` int(1) NOT NULL DEFAULT '1',
  ...
```

The system uses SOAP (Subjective, Objective, Assessment, Plan) format for clinical notes:
```php
class CPPTEntity extends SystemArrayObject
{
    protected $fields = [
        "ID"=>1
        , "KUNJUNGAN"=>1
        , "TANGGAL"=>1
        , "SUBYEKTIF"=>1
        , "OBYEKTIF"=>1
        , "ASSESMENT"=>1
        , "PLANNING"=>1
        , "INSTRUKSI" =>1
        ...
    ];
}
```

## 4. Insurance and Billing

### 4.1 BPJS Integration

BPJS integration is comprehensive and includes:
- Patient verification by NIK or BPJS number
- SEP (Surat Eligibilitas Peserta) generation
- Claim submission
- Referral management
- Class upgrades

Configuration example:
```php
'BPJService' => [
    'url' => 'https://apijkn-dev.bpjs-kesehatan.go.id/vclaim-rest-dev',
    'id' => '[CONSUMER ID DARI BPJS]',
    'key' => '[CONSUMER SECRET DARI BPJS]',
    'userKey' => '[USER KEY DARI BPJS]',
    'timezone' => 'UTC',
    'addTime' => 'PT0M',
    'koders' => '1801R001',
    'name' => 'VClaim',
    'version' => '2.0',
    'writeLog' => false,
    ...
]
```

### 4.2 Billing Codes and Processes

The system uses:
- INA-CBG codes for case-based payments
- Fee-for-service billing for non-BPJS patients
- Integration with INA-CBG grouper for tariff calculation

### 4.3 Claims Submission

Claims are submitted through:
- BPJS VClaim API for national health insurance
- Custom interfaces for other insurance providers
- INA-CBG integration for case-based payments

### 4.4 Required Reporting

The system generates required reports for:
- BPJS claims reconciliation
- Hospital performance indicators (BOR, LOS, etc.)
- Disease surveillance

## 5. Regulatory Compliance

### 5.1 Patient Consent Mechanisms

The system implements consent management:
```sql
ALTER TABLE `pendaftaran`
    ADD COLUMN `CONSENT_SATUSEHAT` TINYINT(1) NOT NULL DEFAULT '0' COMMENT '0 = Tidak Disetujui, 1 = Disetujui' AFTER `JAM_LAHIR`,
    ADD INDEX `CONSENT_SATUSEHAT` (`CONSENT_SATUSEHAT`);
```

Consent is tracked for:
- SatuSehat (national health information exchange)
- Data sharing with third parties
- Specific procedures (informed consent)

### 5.2 Data Privacy

Data privacy is handled through:
- Encryption of sensitive data
- Role-based access control
- Audit trails for data access
- Secure API communications

```php
// Example of data encryption
private function encryptData($data) {
    if($this->authGranted) {
        $key = $this->tokenStorage->read();
        if($key) {
            $key = (array) $key;
            $this->crypto->setKey($key["TOKEN"]);
            $content = (json_encode($data));
            $data = $this->crypto->encrypt($content, true, true);
        }
    }
    return $data;
}
```

### 5.3 Ministry of Health Reporting

The system includes modules for mandatory reporting to:
- RS Online (hospital online reporting)
- SIRS (hospital information system reporting)
- TB reporting system (SITB)
- COVID-19 surveillance

### 5.4 Other Compliance Requirements

Additional compliance features include:
- Digital signature integration (TTE module)
- Medical record retention policies
- Audit trails for regulatory compliance

## 6. User Interface Patterns

### 6.1 Indonesian Healthcare Workflows

The UI represents Indonesian healthcare workflows through:
- Registration and triage process
- Outpatient and inpatient management
- BPJS verification and SEP generation
- Referral management

### 6.2 Terminology and Labeling

The system uses Indonesian healthcare terminology:
- Poli (outpatient clinic)
- Rawat Inap/Rawat Jalan (inpatient/outpatient)
- DPJP (Dokter Penanggung Jawab Pelayanan - attending physician)
- Rujukan (referral)

### 6.3 Date, Time, and Number Formatting

The system uses Indonesian formatting conventions:
- DD-MM-YYYY date format
- 24-hour time format
- Decimal numbers with comma as separator

### 6.4 Cultural Considerations

Cultural considerations in the interface include:
- Religion as a standard demographic field
- Family relationship tracking
- Honorific titles (Gelar_Depan, Gelar_Belakang)

## 7. Integration Points

### 7.1 External System Integration

The system integrates with multiple external systems:

1. **BPJS**
   - VClaim for insurance verification and claims
   - P-Care for primary care integration
   - INA-CBG for case-based payment

2. **Dukcapil**
   - NIK verification
   - Family card (KK) data retrieval

3. **Kemenkes (Ministry of Health)**
   - RS Online for hospital reporting
   - SIRS for statistical reporting
   - SITB for tuberculosis reporting

4. **Laboratory Information Systems**
   - LIS integration for lab results

### 7.2 APIs and Integration Standards

The system uses various integration standards:
- REST APIs for most integrations
- FHIR for health information exchange
- Custom XML/JSON formats for legacy systems

### 7.3 Government System Data Exchange

Data exchange with government systems includes:
- Encrypted communications
- Digital signatures
- Standardized message formats
- Audit logging

## 8. Answers to Specific Questions

### 8.1 Mandatory Fields for Patient Registration

Mandatory fields for patient registration according to Indonesian regulations:
- Full name
- NIK (National ID)
- Date of birth
- Gender
- Address (including RT/RW)
- Contact information

### 8.2 BPJS Verification Process

The BPJS verification process is implemented through:
1. NIK or BPJS number lookup via VClaim API
2. Verification of membership status and class
3. Storage of verification results
4. SEP generation for eligible patients

### 8.3 Required Public Health Reporting

Required reporting for Indonesian public health authorities:
- Communicable disease surveillance
- Hospital utilization statistics
- Mortality data
- TB and HIV program reporting
- COVID-19 reporting

### 8.4 Medical Records Structure

Medical records are structured to comply with Indonesian standards through:
- SOAP format clinical notes
- Standardized assessment forms
- ICD-10 and ICD-9-CM coding
- Required signatures and timestamps

### 8.5 Indonesia-specific Clinical Pathways

The system implements several Indonesia-specific clinical pathways:
- TB management protocol
- Maternal and child health pathways
- Dengue fever management
- COVID-19 protocols

### 8.6 Prescription Handling

Prescriptions are handled in accordance with Indonesian regulations through:
- Electronic prescribing with digital signatures
- Controlled substance tracking
- Integration with pharmacy systems
- BPJS formulary compliance checking

## 9. Recommendations for CARE Implementation

Based on this analysis, we recommend the following for implementing the Indonesian version of CARE:

1. **Patient Identification**
   - Implement NIK, BPJS, and NORM as primary identifiers
   - Include family card (KK) tracking
   - Support Indonesian naming conventions with titles/honorifics

2. **Healthcare Provider Management**
   - Support Indonesian facility categorization (RS, Puskesmas, Klinik)
   - Implement provider credentialing with SIP and specialization
   - Configure role-based access aligned with Indonesian regulations

3. **Clinical Data**
   - Implement ICD-10 and ICD-9-CM coding
   - Support SOAP format clinical documentation
   - Include specialized forms for TB, maternal health, etc.

4. **Insurance Integration**
   - Develop comprehensive BPJS integration
   - Support INA-CBG grouping and claims
   - Implement SEP generation and management

5. **Regulatory Compliance**
   - Implement consent management for SatuSehat
   - Support required Ministry of Health reporting
   - Ensure data privacy compliance

6. **User Interface**
   - Use Indonesian healthcare terminology
   - Implement Indonesian date and number formats
   - Design workflows aligned with Indonesian healthcare processes

7. **External Integrations**
   - Prioritize BPJS, Dukcapil, and Kemenkes integrations
   - Implement FHIR standards for interoperability
   - Support legacy system integration where needed

## 10. Conclusion

The Indonesian EMR system analyzed provides a comprehensive blueprint for implementing a localized version of CARE. By incorporating the identified patient data structures, healthcare provider information, clinical data models, insurance integration, regulatory compliance features, and user interface patterns, the CARE system can be effectively adapted to meet Indonesian healthcare requirements while maintaining compatibility with the core CARE system.

The most critical aspects to focus on are BPJS integration, support for Indonesian patient identifiers, compliance with Ministry of Health reporting requirements, and implementation of Indonesia-specific clinical workflows. By prioritizing these areas, the CARE system can be successfully adapted for the Indonesian healthcare context.
