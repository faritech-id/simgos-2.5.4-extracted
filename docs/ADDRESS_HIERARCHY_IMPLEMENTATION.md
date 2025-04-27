# Indonesian Address Hierarchy Implementation for OpenMRS

This document describes the implementation of the Indonesian address hierarchy system in OpenMRS using the Initializer module.

## Directory Structure
```
configuration/
├── addresshierarchy/
│   ├── addressConfiguration.csv    # Defines hierarchy levels
│   └── addresshierarchy.csv       # Contains location data
├── globalproperties/
│   └── addresshierarchy.xml       # Global configuration settings
└── metadatamapping/
    └── addresshierarchylevels.csv # Metadata mappings for levels
```

## Address Hierarchy Configuration

### Level Structure (addressConfiguration.csv)
The address hierarchy is structured as follows:
- Country (required)
- Province (required)
- District/City (required)
- Sub-district (required)
- RT (Rukun Tetangga - optional)
- RW (Rukun Warga - optional)
- Street Address (required)
- Additional Address (optional)
- Postal Code (optional)

### Location Data (addresshierarchy.csv)
Contains the actual location data in a hierarchical format:
```csv
Country,Province,District/City,Sub-district,RT,RW
Indonesia,DKI Jakarta,Jakarta Pusat,Menteng,001,001
```

### Global Properties (addresshierarchy.xml)
Configuration settings for the address hierarchy module:
- `addresshierarchy.starter.validation`: Enable validation
- `addresshierarchy.mandatory`: Make hierarchy mandatory
- `addresshierarchy.allowFreeText`: Allow free text entry
- `addresshierarchy.enableOverride`: Allow validation override

### Metadata Mapping (addresshierarchylevels.csv)
Maps each level to OpenMRS metadata:
```csv
Name,Description,Parent,AddressField,Required,UUID
Country,Country level,NULL,country,true,[UUID]
```

## Implementation Details

### Field Mappings
1. **Administrative Levels**
   - Province (Provinsi) → stateProvince
   - District/City (Kabupaten/Kota) → district
   - Sub-district (Kecamatan) → cityVillage
   - RT/RW → Custom fields

2. **Address Components**
   - Street Address → address1
   - Additional Address → address2
   - Postal Code → postalCode

### Validation Rules
1. **Format Validation**
   - RT/RW: Numeric values
   - Postal Code: 5 digits
   - Administrative Codes: Proper length and format

2. **Required Fields**
   - Country
   - Province
   - District/City
   - Sub-district
   - Street Address

### User Interface Behavior
1. **Cascading Dropdowns**
   - Selection flows from top (Country) to bottom (RT/RW)
   - Each selection filters options in child dropdowns

2. **Data Entry**
   - Free text allowed (configurable)
   - Validation can be overridden (configurable)
   - Auto-completion available for known values

## Import Instructions

1. **Prerequisites**
   - OpenMRS Platform 2.x or higher
   - Address Hierarchy module installed
   - Initializer module installed

2. **Installation Steps**
   ```bash
   # 1. Create the directory structure
   mkdir -p configuration/{addresshierarchy,globalproperties,metadatamapping}

   # 2. Copy configuration files
   cp addressConfiguration.csv configuration/addresshierarchy/
   cp addresshierarchy.csv configuration/addresshierarchy/
   cp addresshierarchy.xml configuration/globalproperties/
   cp addresshierarchylevels.csv configuration/metadatamapping/

   # 3. Restart OpenMRS
   ```

3. **Verification**
   - Check Address Hierarchy module settings
   - Verify dropdown cascading behavior
   - Test address entry with validation

## Administrative Code Handling

The system handles administrative codes internally while presenting user-friendly names:

1. **Province Codes**
   - 2-digit format (e.g., "31" for DKI Jakarta)
   - Automatically managed behind the scenes

2. **District/City Codes**
   - 4-digit format (e.g., "3171" for Jakarta Pusat)
   - First 2 digits match province code

3. **Sub-district Codes**
   - 6-digit format (e.g., "317101" for Menteng)
   - First 4 digits match district code

4. **RT/RW Format**
   - 3-digit format each (e.g., "001/002")
   - Stored separately from other administrative codes

## Customization

To customize this implementation:

1. **Adding Locations**
   - Add rows to addresshierarchy.csv
   - Follow the existing format
   - Maintain hierarchical relationships

2. **Modifying Validation**
   - Edit addresshierarchy.xml properties
   - Adjust validation rules as needed

3. **Changing Required Fields**
   - Modify Required column in addressConfiguration.csv
   - Update corresponding metadata mapping

## Troubleshooting

Common issues and solutions:

1. **Hierarchy Not Loading**
   - Check file permissions
   - Verify CSV format
   - Confirm module installation

2. **Validation Errors**
   - Check format of administrative codes
   - Verify parent-child relationships
   - Confirm required fields

3. **UI Issues**
   - Clear browser cache
   - Check for JavaScript errors
   - Verify module compatibility 