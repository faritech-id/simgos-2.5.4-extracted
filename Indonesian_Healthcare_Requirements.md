# Indonesian Healthcare Requirements Analysis

## Executive Summary

This document provides a comprehensive analysis of Indonesian healthcare requirements based on examination of an existing government EMR system. The focus is on domain knowledge about Indonesian healthcare practices, standards, and regulatory requirements that must be accommodated in a modern EMR system built on the CARE platform, regardless of technical implementation.

## 1. Patient Information Requirements

### 1.1 Mandatory Patient Identifiers

The following patient identifiers are mandatory in Indonesia:

- **NIK (Nomor Induk Kependudukan)**: 16-digit national ID number, primary identifier for citizens
- **NORM (Nomor Rekam Medis)**: Medical record number, unique within each healthcare facility
- **BPJS Number (Nomor Kartu BPJS)**: National health insurance number for those enrolled
- **No KK (Nomor Kartu Keluarga)**: Family card number linking individuals to family units

Additional identifiers that may be required in specific contexts:
- **NIKS**: Temporary resident number for non-citizens
- **Passport Number**: For foreign patients
- **Birth Certificate Number**: For newborns without NIK

### 1.2 Required Demographic Information

The following demographic information must be collected according to Indonesian regulations:

- **Full name** (including honorifics/titles)
- **Place of birth** (city/regency)
- **Date of birth**
- **Gender** (Laki-laki/Perempuan - Male/Female)
- **Blood type** (Golongan Darah)
- **Religion** (Agama) - Indonesia recognizes 6 official religions: Islam, Protestant, Catholic, Hindu, Buddhist, and Confucian
- **Marital status** (Status Perkawinan)
- **Education level** (Pendidikan)
- **Occupation** (Pekerjaan)
- **Contact information** (phone number, email)
- **Emergency contact** (name, relationship, contact number)

### 1.3 Family Relationship Information

Family relationship information that must be tracked:

- **Family card number** (Nomor KK)
- **Relationship to head of family** (Hubungan Keluarga):
  - Kepala Keluarga (Head of Family)
  - Istri/Suami (Wife/Husband)
  - Anak (Child)
  - Menantu (Son/Daughter-in-law)
  - Cucu (Grandchild)
  - Orang Tua (Parent)
  - Mertua (Parent-in-law)
  - Famili Lain (Other Family)
  - Pembantu (Household Helper)
  - Lainnya (Other)
- **Mother's full name** (Nama Ibu Kandung) - important for identification verification
- **Father's full name** (Nama Ayah Kandung)

### 1.4 Indonesia-Specific Patient Categorizations

Specific categorizations of patients unique to Indonesia:

- **BPJS class** (Kelas BPJS): Class 1, 2, or 3 determining hospital accommodation
- **Patient type** (Jenis Pasien):
  - Umum (General/Self-pay)
  - BPJS-PBI (Government-subsidized BPJS)
  - BPJS-Non PBI (Self-funded BPJS)
  - Asuransi (Private Insurance)
  - Perusahaan (Company-covered)
  - Jamkesda (Regional Health Insurance)
- **Special program categories**:
  - TB patient (Pasien TB)
  - COVID-19 patient
  - KIA (Kesehatan Ibu dan Anak - Maternal and Child Health)

### 1.5 Standard Address Format

The standard address format in Indonesia includes:

- **Street address** (Alamat)
- **RT (Rukun Tetangga)**: Neighborhood unit, typically 2-3 digits
- **RW (Rukun Warga)**: Community unit, typically 2-3 digits
- **Kelurahan/Desa**: Urban ward/village
- **Kecamatan**: Subdistrict
- **Kabupaten/Kota**: Regency/City
- **Provinsi**: Province
- **Kode Pos**: Postal code (5 digits)

Example format:
```
Jalan Mangga No. 24
RT 003/RW 005
Kelurahan Sukamaju
Kecamatan Cilodong
Kota Depok
Jawa Barat 16415
```

### 1.6 Indonesian Naming Conventions

Indonesian naming conventions include:

- **Gelar Depan**: Title/honorific before name (e.g., Dr., Ir., H. for Haji)
- **Nama**: Full name (may not have separate first/last name components)
- **Gelar Belakang**: Title/honorific after name (e.g., S.H., M.Kom., Ph.D.)
- **Nama Panggilan**: Nickname or preferred name

Many Indonesians use a single name without a family name. When family names exist, they typically come last but are not separated in official documents.

## 2. Healthcare Provider Information

### 2.1 Provider Credentials

Healthcare provider credentials that must be displayed:

- **SIP (Surat Izin Praktik)**: Practice license number
- **STR (Surat Tanda Registrasi)**: Professional registration number
- **Specialization** (Spesialisasi)
- **Academic degrees** (Gelar Akademik)
- **Professional organization membership** (e.g., IDI for doctors)

### 2.2 Healthcare Facility Categorization

Healthcare facilities are categorized as:

- **Rumah Sakit (RS)**: Hospital
  - RSUD (Rumah Sakit Umum Daerah): Regional Public Hospital
  - RSUP (Rumah Sakit Umum Pusat): Central Public Hospital
  - RSU (Rumah Sakit Umum): General Hospital
  - RSK (Rumah Sakit Khusus): Specialized Hospital
  - RS Swasta: Private Hospital
- **Puskesmas**: Community Health Center
  - Puskesmas Rawat Inap: Inpatient Community Health Center
  - Puskesmas Non-Rawat Inap: Outpatient-only Community Health Center
- **Klinik**: Clinic
  - Klinik Pratama: Primary Clinic
  - Klinik Utama: Main Clinic
- **Praktik Mandiri**: Independent Practice
- **Apotek**: Pharmacy
- **Laboratorium**: Laboratory

Each facility has a unique code assigned by the Ministry of Health and BPJS.

### 2.3 Recognized Provider Roles

Provider roles recognized in the Indonesian healthcare system:

- **Dokter**: Doctor
  - Dokter Umum: General Practitioner
  - Dokter Spesialis: Specialist
  - Dokter Gigi: Dentist
- **DPJP (Dokter Penanggung Jawab Pelayanan)**: Attending Physician
- **Perawat**: Nurse
- **Bidan**: Midwife
- **Apoteker**: Pharmacist
- **Ahli Gizi**: Nutritionist
- **Fisioterapis**: Physiotherapist
- **Radiografer**: Radiographer
- **Analis Laboratorium**: Laboratory Analyst
- **Tenaga Administrasi**: Administrative Staff

### 2.4 Provider Information Visible to Patients

Provider information that must be visible to patients:

- Full name with credentials
- Specialization
- Schedule (days and hours available)
- Room/location within facility
- SIP number (practice license)
- Photo (optional but common)

## 3. Clinical Documentation Standards

### 3.1 Clinical Notes Format

The standard format for clinical notes in Indonesia is SOAP:

- **S (Subjektif)**: Subjective information from patient
- **O (Objektif)**: Objective findings from examination
- **A (Asesmen)**: Assessment/diagnosis
- **P (Perencanaan)**: Plan for treatment

Additional documentation formats include:
- **SBAR** (Situation, Background, Assessment, Recommendation) for handoffs
- **ADIME** (Assessment, Diagnosis, Intervention, Monitoring, Evaluation) for nutritional assessments

### 3.2 Diagnosis Coding Systems

Diagnosis coding systems used in Indonesia:

- **ICD-10** (International Classification of Diseases, 10th revision) for diagnoses
- **ICD-9-CM** for procedures
- **ICHI** (International Classification of Health Interventions) - being adopted
- **INA-CBG** codes for case-based payment grouping

### 3.3 Specialized Clinical Documentation

Specialized clinical documentation required for specific conditions:

- **TB Documentation**:
  - TB01 form for case registration
  - TB06 form for treatment monitoring
  - SITB (Sistem Informasi Tuberkulosis) reporting
  
- **Maternal Health Documentation**:
  - KIA (Kesehatan Ibu dan Anak) book
  - ANC (Antenatal Care) visit records
  - Partograph for labor monitoring
  - Postpartum monitoring
  
- **COVID-19 Documentation**:
  - Case investigation form
  - Contact tracing form
  - Isolation/quarantine monitoring

### 3.4 Standard Vital Signs

Standard vital signs collected and their display format:

- **Tekanan Darah (Blood Pressure)**: systolic/diastolic in mmHg
- **Nadi (Pulse)**: beats per minute (bpm)
- **Respirasi (Respiratory Rate)**: breaths per minute
- **Suhu (Temperature)**: in Celsius (°C)
- **Tinggi Badan (Height)**: in centimeters (cm)
- **Berat Badan (Weight)**: in kilograms (kg)
- **Lingkar Kepala (Head Circumference)**: for infants, in centimeters (cm)
- **Indeks Massa Tubuh (Body Mass Index)**: calculated from height and weight
- **Skala Nyeri (Pain Scale)**: typically 0-10

### 3.5 Medication Information Requirements

Medication information that must be captured in prescriptions:

- **Nama Obat**: Drug name (generic and brand)
- **Dosis**: Dosage
- **Frekuensi**: Frequency (e.g., 3x1 means three times daily, one tablet each time)
- **Cara Pemberian**: Route of administration
- **Jumlah**: Quantity
- **Aturan Pakai**: Usage instructions
- **Tanggal Resep**: Prescription date
- **Nama dan SIP Dokter**: Prescribing doctor's name and license number
- **Tanda Tangan Dokter**: Doctor's signature (physical or electronic)
- **Informasi Pasien**: Patient information

## 4. BPJS (National Health Insurance) Requirements

### 4.1 BPJS Verification Information

Patient information required for BPJS verification:

- **Nomor Kartu BPJS**: BPJS card number
- **NIK**: National ID number
- **Nama Lengkap**: Full name
- **Tanggal Lahir**: Date of birth
- **Faskes Tingkat Pertama**: Primary healthcare facility

### 4.2 SEP (Surat Eligibilitas Peserta)

The SEP (Surat Eligibilitas Peserta) is a participant eligibility letter required for BPJS-covered services. Information it must contain:

- **Nomor SEP**: SEP number
- **Tanggal SEP**: SEP issue date
- **Nomor Kartu BPJS**: BPJS card number
- **Nama Peserta**: Participant name
- **Tanggal Lahir**: Date of birth
- **Jenis Kelamin**: Gender
- **Poli Tujuan**: Destination clinic/department
- **Kelas Rawat**: Inpatient class
- **Jenis Pelayanan**: Service type (outpatient/inpatient)
- **Diagnosa Awal**: Initial diagnosis
- **Faskes Perujuk**: Referring facility (if applicable)
- **Nomor Rujukan**: Referral number (if applicable)
- **Catatan**: Notes
- **DPJP**: Attending physician

### 4.3 Referral Management Information

Information needed for referral management:

- **Faskes Perujuk**: Referring facility
- **Faskes Tujuan**: Destination facility
- **Nomor Rujukan**: Referral number
- **Tanggal Rujukan**: Referral date
- **Diagnosa**: Diagnosis
- **Tipe Rujukan**: Referral type (horizontal/vertical)
- **Poli Tujuan**: Destination clinic/department
- **Dokter Perujuk**: Referring doctor
- **Catatan**: Notes

### 4.4 BPJS Class Categories

BPJS class categories and upgrade information:

- **Kelas 3**: Basic ward (shared room with multiple beds)
- **Kelas 2**: Medium ward (shared room with fewer beds)
- **Kelas 1**: Premium ward (shared room with 2-3 beds)
- **VIP/VVIP**: Private rooms (not covered by BPJS, requires upgrade)

For class upgrades (naik kelas):
- **Kelas Hak**: Entitled class based on membership
- **Kelas Rawat**: Actual inpatient class
- **Pembiayaan**: Funding source for the difference
- **Penanggung Jawab**: Person responsible for additional payment
- **Upgrade Fee**: Additional cost for class upgrade

### 4.5 BPJS Verification Display Requirements

Information that must be displayed during the verification process:

- **Status Kepesertaan**: Membership status (Active/Inactive)
- **Kelas Hak**: Entitled class
- **Jenis Peserta**: Participant type (PBI/Non-PBI)
- **Faskes Tingkat Pertama**: Primary healthcare facility
- **Tanggal TMT**: Membership start date
- **Tanggal TAT**: Membership end date
- **Informasi Premi**: Premium information
- **Status Verification**: Success/Failure message

## 5. Cultural and Localization Requirements

### 5.1 Indonesian Healthcare Terminology

Essential Indonesian healthcare terminology for the interface:

- **Rawat Jalan**: Outpatient care
- **Rawat Inap**: Inpatient care
- **Gawat Darurat**: Emergency
- **Poli**: Clinic/department
- **Rujukan**: Referral
- **Resep**: Prescription
- **Pemeriksaan**: Examination
- **Tindakan**: Procedure
- **Laboratorium**: Laboratory
- **Radiologi**: Radiology
- **Rekam Medis**: Medical record
- **Anamnesis**: Medical history taking
- **Pemeriksaan Fisik**: Physical examination
- **Pengobatan**: Treatment
- **Pembayaran**: Payment

### 5.2 Date, Time, and Number Formats

Standard formats in Indonesia:

- **Date**: DD-MM-YYYY or DD/MM/YYYY (e.g., 31-12-2023)
- **Time**: 24-hour format (e.g., 14:30)
- **Numbers**: Decimal comma, period as thousand separator (e.g., 1.000,50)
- **Currency**: Rp (Rupiah) followed by amount (e.g., Rp 150.000)
- **Phone numbers**: +62 format for country code (e.g., +62 812 3456 7890)

### 5.3 Cultural Factors

Cultural factors that must be captured:

- **Religion** (Agama): Important for dietary restrictions, end-of-life care
- **Education level** (Pendidikan): Affects communication approach
- **Ethnicity** (Suku): May affect genetic predispositions and cultural practices
- **Language preference** (Bahasa): Primary language for communication
- **Cultural practices**: Relevant to care (e.g., fasting during Ramadan)

### 5.4 Regional Language Requirements

Indonesia has over 700 languages, but the primary requirements are:

- **Bahasa Indonesia**: National language, must be supported
- **Regional languages**: Consider support for major regional languages:
  - Javanese (Jawa)
  - Sundanese (Sunda)
  - Batak
  - Minangkabau
  - Balinese (Bali)
  - Acehnese (Aceh)
  - Buginese (Bugis)

Most healthcare documentation is in Bahasa Indonesia, but patient communication may require regional languages.

## 6. Regulatory Compliance

### 6.1 Patient Consent Requirements

Patient consent information that must be captured:

- **General treatment consent** (Persetujuan Tindakan Umum)
- **Specific procedure consent** (Informed Consent Tindakan)
- **Data sharing consent** (Persetujuan Berbagi Data)
- **SatuSehat consent** (national health information exchange)
- **Research participation consent** (if applicable)
- **Photo/video consent** (if applicable)

Each consent must include:
- Patient/guardian name
- Relationship to patient (if guardian)
- Date and time
- Signature
- Witness signature (for major procedures)

### 6.2 Medical Record Requirements

Information that must be included in medical records according to Indonesian regulations:

- **Patient identification** (name, medical record number, date of birth)
- **Visit information** (date, time, department)
- **Chief complaint** (keluhan utama)
- **Medical history** (riwayat penyakit)
- **Physical examination findings** (pemeriksaan fisik)
- **Supporting examination results** (hasil pemeriksaan penunjang)
- **Diagnosis** (diagnosa)
- **Treatment/procedure** (pengobatan/tindakan)
- **Medications prescribed** (obat yang diberikan)
- **Healthcare provider information** (name, license number, signature)
- **Consent forms** (formulir persetujuan)
- **Progress notes** (catatan perkembangan)
- **Discharge summary** (for inpatients)

### 6.3 Ministry of Health Reporting

Information that must be collected for Ministry of Health submissions:

- **Hospital statistics** (RL - Rekap Laporan):
  - RL 1: Facility data
  - RL 2: Service utilization
  - RL 3: Hospital resources
  - RL 4: Morbidity/mortality data
  - RL 5: Disease surveillance
- **Communicable disease reporting**:
  - TB cases
  - HIV/AIDS
  - COVID-19
  - Other notifiable diseases
- **Maternal and child health reporting**
- **Hospital performance indicators**:
  - BOR (Bed Occupancy Rate)
  - ALOS (Average Length of Stay)
  - TOI (Turn Over Interval)
  - BTO (Bed Turn Over)
  - NDR (Net Death Rate)
  - GDR (Gross Death Rate)

### 6.4 Privacy Notices and Disclosures

Privacy notices and disclosures that must be shown to patients:

- **Data collection purpose** (tujuan pengumpulan data)
- **Data usage policy** (kebijakan penggunaan data)
- **Data sharing information** (informasi pembagian data)
- **Patient rights regarding their data** (hak pasien terhadap data)
- **Data retention policy** (kebijakan penyimpanan data)
- **Contact information for privacy concerns** (kontak untuk masalah privasi)

## 7. Workflow Requirements

### 7.1 Patient Registration Workflow

Standard patient registration workflow in Indonesian healthcare:

1. **Pendaftaran** (Registration):
   - New patient registration or existing patient verification
   - Insurance verification (BPJS/private)
   - SEP generation for BPJS patients
   - Payment method selection

2. **Triase** (Triage):
   - Initial assessment
   - Priority determination
   - Department assignment

3. **Antrian** (Queue):
   - Queue number assignment
   - Waiting area direction

### 7.2 Outpatient Visit Process

Standard outpatient visit process flow:

1. **Registration/check-in**
2. **Vital signs measurement** by nurse
3. **Consultation with doctor**:
   - History taking
   - Physical examination
   - Diagnosis
   - Treatment plan
4. **Supporting examinations** (if needed):
   - Laboratory
   - Radiology
   - Other diagnostics
5. **Prescription** (if needed)
6. **Procedure** (if needed)
7. **Follow-up appointment scheduling**
8. **Payment/billing**
9. **Pharmacy** for medication dispensing

### 7.3 Inpatient Admission and Discharge

Standard inpatient admission and discharge process:

**Admission Process**:
1. **Decision for admission** by doctor
2. **Administrative processing**:
   - SEP generation/verification for BPJS
   - Deposit payment for non-BPJS
   - Consent forms
3. **Bed assignment**
4. **Initial assessment** by nurse
5. **Treatment plan documentation**

**Discharge Process**:
1. **Discharge planning** by healthcare team
2. **Discharge summary preparation**
3. **Medication reconciliation**
4. **Discharge instruction**
5. **Final billing calculation**
6. **Payment processing**
7. **Follow-up appointment scheduling**
8. **Actual discharge** from facility

### 7.4 Referral Handling

Standard referral handling process:

1. **Referral decision** by doctor
2. **Referral form preparation**:
   - Patient information
   - Clinical summary
   - Reason for referral
   - Destination facility
3. **BPJS referral approval** (if applicable)
4. **Appointment scheduling** at destination facility
5. **Patient education** about referral
6. **Referral tracking**
7. **Feedback from destination facility**

### 7.5 Medication Dispensing Workflow

Standard medication dispensing workflow:

1. **Prescription entry** by doctor
2. **Prescription verification** by pharmacist:
   - Dose checking
   - Interaction checking
   - Formulary compliance (for BPJS)
3. **Medication preparation**
4. **Final verification**
5. **Patient education** about medication
6. **Medication dispensing**
7. **Documentation**

## 8. Document Requirements

### 8.1 Required Medical Documents

Medical documents that must be generated for patients:

- **Kartu Identitas Berobat**: Treatment identity card
- **Surat Eligibilitas Peserta (SEP)**: BPJS eligibility letter
- **Resep Obat**: Prescription
- **Surat Rujukan**: Referral letter
- **Surat Keterangan Sakit**: Sick leave certificate
- **Surat Keterangan Sehat**: Health certificate
- **Ringkasan Medis**: Medical summary
- **Hasil Pemeriksaan Laboratorium**: Laboratory results
- **Hasil Pemeriksaan Radiologi**: Radiology results
- **Surat Keterangan Lahir**: Birth certificate
- **Surat Keterangan Kematian**: Death certificate

### 8.2 Standard Forms

Standard forms required in Indonesian healthcare:

- **Formulir Pendaftaran**: Registration form
- **Formulir Persetujuan Tindakan Medis**: Medical procedure consent form
- **Formulir Penolakan Tindakan Medis**: Medical procedure refusal form
- **Formulir Permintaan Rekam Medis**: Medical record request form
- **Formulir Asesmen Awal**: Initial assessment form
- **Formulir Asesmen Ulang**: Reassessment form
- **Formulir Edukasi Pasien**: Patient education form
- **Formulir Discharge Planning**: Discharge planning form
- **Formulir Transfer**: Transfer form
- **Formulir Do Not Resuscitate (DNR)**: DNR form (when applicable)

### 8.3 Required Signatures and Approvals

Signatures and approvals required on clinical documentation:

- **Doctor's signature** on:
  - Prescriptions
  - Medical certificates
  - Procedure orders
  - Discharge summaries
  - Referral letters
  - Death certificates
  
- **Patient/guardian signature** on:
  - Consent forms
  - Refusal of treatment forms
  - Discharge against medical advice forms
  - Privacy acknowledgments
  
- **Nurse's signature** on:
  - Nursing assessments
  - Medication administration records
  - Patient education forms
  
- **Witness signatures** on:
  - Major procedure consent forms
  - End-of-life decisions

### 8.4 Discharge Summary Requirements

Information that must be included in discharge summaries:

- **Patient identification** information
- **Admission date and discharge date**
- **Admission diagnosis and discharge diagnosis**
- **Brief history of present illness**
- **Significant findings**
- **Procedures performed**
- **Treatment provided**
- **Medications at discharge**
- **Patient's condition at discharge**
- **Follow-up instructions**
- **Attending physician information and signature**

## 9. Regional Variations

### 9.1 Provincial Healthcare Systems

Notable regional variations within Indonesia:

- **Jakarta**: BPJS integration with Jakarta Sehat program
- **Yogyakarta**: Integration with Jamkesda Yogyakarta
- **Bali**: Special cultural considerations for Hindu practices
- **Aceh**: Sharia-compliant healthcare considerations
- **Papua and remote areas**: Adaptations for limited connectivity

### 9.2 Special Autonomous Regions

Special considerations for autonomous regions:

- **Aceh**: Special autonomy with Sharia influences on healthcare
- **Papua**: Special autonomy with adaptations for indigenous populations
- **Yogyakarta**: Special region status with traditional Javanese influences

## 10. Recommendations for Implementation

Based on this analysis, we recommend the following for implementing the Indonesian version of CARE:

1. **Patient Management**
   - Implement all mandatory Indonesian identifiers (NIK, BPJS, NORM, KK)
   - Support Indonesian address format with RT/RW
   - Include religious and cultural information fields
   - Support Indonesian naming conventions with titles

2. **Provider Management**
   - Include all required credentials (SIP, STR)
   - Support Indonesian facility categorization
   - Implement DPJP assignment workflow

3. **Clinical Documentation**
   - Implement SOAP format for clinical notes
   - Support ICD-10 and ICD-9-CM coding
   - Include specialized forms for TB, maternal health, etc.

4. **BPJS Integration**
   - Develop comprehensive SEP generation workflow
   - Support class upgrades and referral management
   - Implement BPJS verification displays

5. **Localization**
   - Use Indonesian healthcare terminology
   - Implement Indonesian date, time, and number formats
   - Support Bahasa Indonesia with consideration for regional languages

6. **Regulatory Compliance**
   - Implement all required consent mechanisms
   - Support Ministry of Health reporting requirements
   - Include privacy notices and disclosures

7. **Workflow Support**
   - Design registration workflow aligned with Indonesian practices
   - Implement standard outpatient and inpatient processes
   - Support referral and medication workflows

8. **Document Generation**
   - Create templates for all required medical documents
   - Support electronic and physical signature requirements
   - Implement standard forms with proper approvals

## 11. Conclusion

The Indonesian healthcare system has unique requirements shaped by national regulations, cultural factors, and established practices. By incorporating these requirements into the CARE platform, we can create an EMR system that is fully adapted to the Indonesian context while leveraging modern technology to improve healthcare delivery.

The most critical aspects to focus on are BPJS integration, support for Indonesian patient identifiers, compliance with Ministry of Health reporting requirements, and implementation of Indonesia-specific clinical workflows. By prioritizing these areas, the CARE system can be successfully adapted for the Indonesian healthcare context.
