# BPJS VClaim API Reference

## Overview

This document provides detailed technical information about integrating with BPJS Kesehatan's VClaim API, focusing on participant verification and SEP (Surat Eligibilitas Peserta) generation. This reference is based on the implementation found in the existing Indonesian EMR system.

## Base URLs

```
# Production Environment
https://new-api.bpjs-kesehatan.go.id/new-vclaim-rest/

# Development Environment
https://dvlp.bpjs-kesehatan.go.id/vclaim-rest-dev/

# Demo Environment
https://apijkn-dev.bpjs-kesehatan.go.id/vclaim-rest/
```

## Authentication

### Configuration Requirements

The following configuration parameters are required:

```php
'BPJService' => [
    'url' => 'https://apijkn-dev.bpjs-kesehatan.go.id/vclaim-rest-dev',
    'id' => '[CONSUMER ID DARI BPJS]',
    'key' => '[CONSUMER SECRET DARI BPJS]',
    'userKey' => '[USER KEY DARI BPJS]',
    'timezone' => 'UTC',
    'addTime' => 'PT0M',
    'koders' => '1801R001',  // Hospital code
    'name' => 'VClaim',
    'version' => '2.0',
    'writeLog' => false,
]
```

### Authentication Headers

Every request to the VClaim API must include the following headers:

```php
$headers = [
    "Accept: application/Json",
    "X-cons-id: " . $config["id"],
    "X-timestamp: " . $timestamp,
    "X-signature: " . $signature,
    "user_key: " . $config["userKey"]
];
```

### Signature Generation

The signature is generated using the following method:

```php
$dt = new DateTime(null, new DateTimeZone($this->config["timezone"]));
$dt->add(new DateInterval($config["addTime"]));
$ts = $dt->getTimestamp();
$var = $config["id"] . "&" . $ts;
$sign = base64_encode(hash_hmac("sha256", utf8_encode($var), utf8_encode($config["key"]), true));
```

## Participant Lookup Endpoints

### 1. Lookup by BPJS Card Number

**Endpoint:** `Peserta/Peserta/{noKartu}`

**Method:** GET

**Parameters:**
- `noKartu`: BPJS card number
- `tglSEP`: Date in format YYYY-MM-DD (optional)

**Example Request:**
```
GET /Peserta/Peserta/0001112223334445?tglSEP=2023-01-15
```

**Example Response:**
```json
{
    "response": {
        "peserta": {
            "noKartu": "0001112223334445",
            "nik": "3671234567890123",
            "norm": "123456",
            "nama": "BUDI SANTOSO",
            "pisa": "1",
            "sex": "L",
            "tglLahir": "1990-01-01",
            "tglCetakKartu": "2019-01-01",
            "kdProvider": "0123A456",
            "nmProvider": "PUSKESMAS CONTOH",
            "kdCabang": "0101",
            "nmCabang": "JAKARTA PUSAT",
            "kdJenisPeserta": "1",
            "nmJenisPeserta": "PESERTA PBI",
            "kdKelas": "3",
            "nmKelas": "Kelas 3",
            "tglTAT": "2023-12-31",
            "tglTMT": "2023-01-01",
            "umurSaatPelayanan": "33",
            "umurSekarang": "33",
            "dinsos": null,
            "iuran": null,
            "noSKTM": null,
            "prolanisPRB": "0",
            "kdStatusPeserta": "0",
            "ketStatusPeserta": "AKTIF"
        }
    },
    "metadata": {
        "message": "OK",
        "code": 200,
        "requestId": "1801R001"
    }
}
```

### 2. Lookup by NIK (National ID)

**Endpoint:** `Peserta/Peserta/nik/{nik}`

**Method:** GET

**Parameters:**
- `nik`: National ID number
- `tglSEP`: Date in format YYYY-MM-DD (optional)

**Example Request:**
```
GET /Peserta/Peserta/nik/3671234567890123?tglSEP=2023-01-15
```

**Example Response:**
```json
{
    "response": {
        "peserta": {
            "noKartu": "0001112223334445",
            "nik": "3671234567890123",
            "norm": "123456",
            "nama": "BUDI SANTOSO",
            "pisa": "1",
            "sex": "L",
            "tglLahir": "1990-01-01",
            "tglCetakKartu": "2019-01-01",
            "kdProvider": "0123A456",
            "nmProvider": "PUSKESMAS CONTOH",
            "kdCabang": "0101",
            "nmCabang": "JAKARTA PUSAT",
            "kdJenisPeserta": "1",
            "nmJenisPeserta": "PESERTA PBI",
            "kdKelas": "3",
            "nmKelas": "Kelas 3",
            "tglTAT": "2023-12-31",
            "tglTMT": "2023-01-01",
            "umurSaatPelayanan": "33",
            "umurSekarang": "33",
            "dinsos": null,
            "iuran": null,
            "noSKTM": null,
            "prolanisPRB": "0",
            "kdStatusPeserta": "0",
            "ketStatusPeserta": "AKTIF"
        }
    },
    "metadata": {
        "message": "OK",
        "code": 200,
        "requestId": "1801R001"
    }
}
```

## SEP Management Endpoints

### 1. SEP Generation

**Endpoint:** `SEP/2.0/insert`

**Method:** POST

**Request Body:**
```json
{
    "request": {
        "t_sep": {
            "noKartu": "0001112223334445",
            "tglSep": "2023-01-15",
            "ppkPelayanan": "1801R001",
            "jnsPelayanan": "2",
            "klsRawat": {
                "klsRawatHak": "3",
                "klsRawatNaik": "",
                "pembiayaan": "",
                "penanggungJawab": ""
            },
            "noMR": "123456",
            "rujukan": {
                "asalRujukan": "1",
                "tglRujukan": "2023-01-10",
                "noRujukan": "RJK0123456789",
                "ppkRujukan": "0123A456"
            },
            "catatan": "Pasien dengan keluhan sakit kepala",
            "diagAwal": "A09",
            "poli": {
                "tujuan": "INT",
                "eksekutif": "0"
            },
            "cob": {
                "cob": "0"
            },
            "katarak": {
                "katarak": "0"
            },
            "jaminan": {
                "lakaLantas": "0",
                "penjamin": "",
                "lokasiLaka": ""
            },
            "tujuanKunj": "0",
            "flagProcedure": "",
            "kdPenunjang": "",
            "assesmentPel": "",
            "dpjpLayan": "12345",
            "noTelp": "081234567890",
            "user": "Admin"
        }
    }
}
```

**Response:**
```json
{
    "response": {
        "sep": {
            "noSep": "1801R00102301150001",
            "tglSep": "2023-01-15",
            "jnsPelayanan": "2",
            "poli": "Poli Penyakit Dalam",
            "diagnosa": "A09 - Diarrhoea and gastroenteritis of presumed infectious origin",
            "peserta": {
                "noKartu": "0001112223334445",
                "nama": "BUDI SANTOSO",
                "tglLahir": "1990-01-01",
                "kelamin": "L"
            },
            "informasi": {
                "dinsos": null,
                "prolanisPRB": null,
                "noSKTM": null
            }
        }
    },
    "metadata": {
        "message": "Sukses",
        "code": 200,
        "requestId": "1801R001"
    }
}
```

### 2. SEP Update

**Endpoint:** `SEP/2.0/update`

**Method:** PUT

**Request Body:**
```json
{
    "request": {
        "t_sep": {
            "noSep": "1801R00102301150001",
            "klsRawat": {
                "klsRawatHak": "3",
                "klsRawatNaik": "2",
                "pembiayaan": "1",
                "penanggungJawab": "Pribadi"
            },
            "noMR": "123456",
            "catatan": "Pasien dengan keluhan sakit kepala dan demam",
            "diagAwal": "A09",
            "poli": {
                "eksekutif": "0"
            },
            "cob": {
                "cob": "0"
            },
            "katarak": {
                "katarak": "0"
            },
            "skdp": {
                "noSurat": "SKP123456",
                "kodeDPJP": "12345"
            },
            "dpjpLayan": "12345",
            "noTelp": "081234567890",
            "user": "Admin"
        }
    }
}
```

**Response:**
```json
{
    "response": {
        "sep": {
            "noSep": "1801R00102301150001",
            "tglSep": "2023-01-15",
            "jnsPelayanan": "2",
            "poli": "Poli Penyakit Dalam",
            "diagnosa": "A09 - Diarrhoea and gastroenteritis of presumed infectious origin",
            "peserta": {
                "noKartu": "0001112223334445",
                "nama": "BUDI SANTOSO",
                "tglLahir": "1990-01-01",
                "kelamin": "L"
            },
            "informasi": {
                "dinsos": null,
                "prolanisPRB": null,
                "noSKTM": null
            }
        }
    },
    "metadata": {
        "message": "Sukses",
        "code": 200,
        "requestId": "1801R001"
    }
}
```

### 3. SEP Deletion

**Endpoint:** `SEP/2.0/delete`

**Method:** DELETE

**Request Body:**
```json
{
    "request": {
        "t_sep": {
            "noSep": "1801R00102301150001",
            "user": "Admin"
        }
    }
}
```

**Response:**
```json
{
    "response": {
        "sep": {
            "noSep": "1801R00102301150001"
        }
    },
    "metadata": {
        "message": "Sukses",
        "code": 200,
        "requestId": "1801R001"
    }
}
```

### 4. SEP Verification

**Endpoint:** `SEP/{noSEP}`

**Method:** GET

**Parameters:**
- `noSEP`: SEP number

**Example Request:**
```
GET /SEP/1801R00102301150001
```

**Example Response:**
```json
{
    "response": {
        "noSep": "1801R00102301150001",
        "tglSep": "2023-01-15",
        "jnsPelayanan": "2",
        "poli": "Poli Penyakit Dalam",
        "diagnosa": "A09 - Diarrhoea and gastroenteritis of presumed infectious origin",
        "peserta": {
            "noKartu": "0001112223334445",
            "nama": "BUDI SANTOSO",
            "tglLahir": "1990-01-01",
            "kelamin": "L"
        },
        "provUmum": {
            "kdProvider": "1801R001",
            "nmProvider": "RS CONTOH"
        },
        "provPerujuk": {
            "kdProviderPerujuk": "0123A456",
            "nmProviderPerujuk": "PUSKESMAS CONTOH",
            "asalRujukan": "1",
            "noRujukan": "RJK0123456789",
            "tglRujukan": "2023-01-10"
        },
        "klsRawat": {
            "klsRawatHak": "Kelas 3",
            "klsRawatNaik": "Kelas 2",
            "pembiayaan": "Pribadi",
            "penanggungJawab": "Pribadi"
        },
        "informasi": {
            "dinsos": null,
            "prolanisPRB": null,
            "noSKTM": null
        }
    },
    "metadata": {
        "message": "OK",
        "code": 200,
        "requestId": "1801R001"
    }
}
```

## Additional SEP Operations

### 1. SEP Application

**Submit Application**

**Endpoint:** `kunjungan/pengajuanSEP`

**Method:** POST

**Request Body:**
```json
{
    "request": {
        "t_sep": {
            "noKartu": "0001112223334445",
            "tglSep": "2023-01-15",
            "jnsPelayanan": "2",
            "keterangan": "Pasien memerlukan pelayanan segera",
            "user": "Admin"
        }
    }
}
```

**Approve Application**

**Endpoint:** `kunjungan/aprovalPengajuanSEP`

**Method:** POST

**Request Body:**
```json
{
    "request": {
        "t_sep": {
            "noKartu": "0001112223334445",
            "tglSep": "2023-01-15",
            "jnsPelayanan": "2",
            "keterangan": "Disetujui",
            "user": "Admin"
        }
    }
}
```

**List Applications**

**Endpoint:** `kunjungan/daftarPengajuan`

**Method:** GET

**Parameters:**
- `tglAwal`: Start date (YYYY-MM-DD)
- `tglAkhir`: End date (YYYY-MM-DD)

**Example Request:**
```
GET /kunjungan/daftarPengajuan?tglAwal=2023-01-01&tglAkhir=2023-01-31
```

**Cancel Application**

**Endpoint:** `kunjungan/batalPengajuanSEP`

**Method:** DELETE

**Request Body:**
```json
{
    "request": {
        "t_sep": {
            "noKartu": "0001112223334445",
            "tglSep": "2023-01-15",
            "jnsPelayanan": "2",
            "keterangan": "Dibatalkan",
            "user": "Admin"
        }
    }
}
```

### 2. INA-CBG Integration

**Endpoint:** `sep/cbg/{noSEP}`

**Method:** GET

**Parameters:**
- `noSEP`: SEP number

**Example Request:**
```
GET /sep/cbg/1801R00102301150001
```

## Error Handling

### Common Error Codes

- `200`: Success
- `201`: Data created successfully
- `400`: Bad request / Invalid parameters
- `401`: Unauthorized (authentication issue)
- `403`: Forbidden (authorization issue)
- `404`: Data not found
- `409`: Conflict (data already exists)
- `412`: Precondition failed
- `500`: Internal server error
- `502`: Bad gateway (BPJS service unavailable)

### Error Response Format

```json
{
    "metadata": {
        "message": "Error message details",
        "code": 400,
        "requestId": "1801R001"
    }
}
```

## Implementation Notes

### 1. Storing Participant Data

After successful participant lookup, it's recommended to store the data locally:

```php
if($result->metadata->code == 200 && (trim($result->metadata->message) == '200' || trim($result->metadata->message) == 'OK')) {
    $peserta = $result->response->peserta;
    $this->storePeserta($norm, $peserta);
}
```

### 2. SEP Generation Process

The typical SEP generation process involves:

1. Verify participant eligibility using the participant lookup endpoint
2. Prepare SEP request data including:
   - Patient information
   - Visit information
   - Referral information
   - Diagnosis information
3. Send SEP generation request
4. Store the generated SEP information locally
5. Link the SEP to the patient's visit record

### 3. Request Signing

All requests must be properly signed using the HMAC-SHA256 algorithm:

```php
$dt = new DateTime(null, new DateTimeZone($this->config["timezone"]));
$dt->add(new DateInterval($config["addTime"]));
$ts = $dt->getTimestamp();
$var = $config["id"]."&".$ts;
$sign = base64_encode(hash_hmac("sha256", utf8_encode($var), utf8_encode($config["key"]), true));
```

## Support Resources

### Documentation

- Main Portal: https://dvlp.bpjs-kesehatan.go.id:8888/trust-mark/
- VClaim Docs: https://dvlp.bpjs-kesehatan.go.id/VClaim-Katalog/
- E-KATALOG: https://e-katalog.bpjs-kesehatan.go.id/

### Technical Support

- Email: vclaim@bpjs-kesehatan.go.id
- Support Portal: https://dvlp.bpjs-kesehatan.go.id/support
- Phone: (021) 424 6063
