<?php
return [
    'controllers' => [
        'factories' => [
            'Kemkes\\IHS\\V1\\Rpc\\Organization\\Controller' => \Kemkes\IHS\V1\Rpc\Organization\OrganizationControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Location\\Controller' => \Kemkes\IHS\V1\Rpc\Location\LocationControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Controller' => \Kemkes\IHS\V1\Rpc\Practitioner\PractitionerControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Patient\\Controller' => \Kemkes\IHS\V1\Rpc\Patient\PatientControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Encounter\\Controller' => \Kemkes\IHS\V1\Rpc\Encounter\EncounterControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Condition\\Controller' => \Kemkes\IHS\V1\Rpc\Condition\ConditionControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Observation\\Controller' => \Kemkes\IHS\V1\Rpc\Observation\ObservationControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Procedure\\Controller' => \Kemkes\IHS\V1\Rpc\Procedure\ProcedureControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Composition\\Controller' => \Kemkes\IHS\V1\Rpc\Composition\CompositionControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Medication\\Controller' => \Kemkes\IHS\V1\Rpc\Medication\MedicationControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\MedicationRequest\\Controller' => \Kemkes\IHS\V1\Rpc\MedicationRequest\MedicationRequestControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Controller' => \Kemkes\IHS\V1\Rpc\MedicationDispanse\MedicationDispanseControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\ServiceRequest\\Controller' => \Kemkes\IHS\V1\Rpc\ServiceRequest\ServiceRequestControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Specimen\\Controller' => \Kemkes\IHS\V1\Rpc\Specimen\SpecimenControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Controller' => \Kemkes\IHS\V1\Rpc\DiagnosticReport\DiagnosticReportControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\Consent\\Controller' => \Kemkes\IHS\V1\Rpc\Consent\ConsentControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\KnowYourCustomer\\Controller' => \Kemkes\IHS\V1\Rpc\KnowYourCustomer\KnowYourCustomerControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\KFA\\Controller' => \Kemkes\IHS\V1\Rpc\KFA\KFAControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\ImagingStudy\\Controller' => \Kemkes\IHS\V1\Rpc\ImagingStudy\ImagingStudyControllerFactory::class,
            'Kemkes\\IHS\\V1\\Rpc\\AllergyIntolerance\\Controller' => \Kemkes\IHS\V1\Rpc\AllergyIntolerance\AllergyIntoleranceControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'kemkes-ihs.rpc.organization' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/organization[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Organization\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.location' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/location[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Location\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.practitioner' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/practisioner[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.patient' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/patient[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Patient\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.encounter' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/encounter[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Encounter\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.condition' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/condition[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Condition\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.observation' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/observation[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Observation\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.procedure' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/procedure[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Procedure\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.composition' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/composition[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Composition\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.medication' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/medication[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Medication\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.medication-request' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/medication/request[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\MedicationRequest\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.medication-dispanse' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/medication/dispanse[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.service-request' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/servicerequest[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\ServiceRequest\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.specimen' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/specimen[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Specimen\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.diagnostic-report' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/diagnosticreport[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.consent' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/consent[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\Consent\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.know-your-customer' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/kyc[/:action][/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\KnowYourCustomer\\Controller',
                        'action' => 'knowYourCustomer',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.poa' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/poa[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\POA\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.pov' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/pov[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\POV\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.bza' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/bza[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\BZA\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.barang-to-poa-pov' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/barang/poapov[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\BarangToPoaPov\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.barang-to-bza' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/barang/bza[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\BarangToBza\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.code-reference' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/codereference[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\CodeReference\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.type-code-reference' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/codereference/type[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\TypeCodeReference\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.kfa' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/kfa[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\KFA\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.sinkronisasi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/sinkronisasi[/:sinkronisasi_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\Sinkronisasi\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.imaging-study' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/imagingstudy[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\ImagingStudy\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.loinc' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/loinc[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\Loinc\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.tindakan-to-loinc' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/tindakantoloinc[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\TindakanToLoinc\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.parameter-hasil-to-loinc' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/parameterhasiltoloinc[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\ParameterHasilToLoinc\\Controller',
                    ],
                ],
            ],
            'kemkes\\ihs.rest.snomed-ct' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/snomedct[/:id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rest\\SnomedCt\\Controller',
                    ],
                ],
            ],
            'kemkes-ihs.rpc.allergy-intolerance' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/ihs/allergyintolerance[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z]*$',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\IHS\\V1\\Rpc\\AllergyIntolerance\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'kemkes-ihs.rpc.organization',
            1 => 'kemkes-ihs.rpc.location',
            2 => 'kemkes-ihs.rpc.practitioner',
            3 => 'kemkes-ihs.rpc.patient',
            4 => 'kemkes-ihs.rpc.encounter',
            5 => 'kemkes-ihs.rpc.condition',
            6 => 'kemkes-ihs.rpc.observation',
            7 => 'kemkes-ihs.rpc.procedure',
            8 => 'kemkes-ihs.rpc.composition',
            9 => 'kemkes-ihs.rpc.medication',
            10 => 'kemkes-ihs.rpc.medication-request',
            11 => 'kemkes-ihs.rpc.medication-dispanse',
            12 => 'kemkes-ihs.rpc.service-request',
            13 => 'kemkes-ihs.rpc.specimen',
            14 => 'kemkes-ihs.rpc.diagnostic-report',
            15 => 'kemkes-ihs.rpc.consent',
            16 => 'kemkes-ihs.rpc.know-your-customer',
            17 => 'kemkes\\ihs.rest.sinkronisasi',
            18 => 'kemkes\\ihs.rest.pov',
            19 => 'kemkes\\ihs.rest.bza',
            20 => 'kemkes\\ihs.rest.barang-to-poa-pov',
            21 => 'kemkes\\ihs.rest.barang-to-bza',
            22 => 'kemkes\\ihs.rest.code-reference',
            23 => 'kemkes\\ihs.rest.type-code-reference',
            24 => 'kemkes-ihs.rpc.kfa',
            25 => 'kemkes-ihs.rpc.imaging-study',
            26 => 'kemkes\\ihs.rest.loinc',
            27 => 'kemkes\\ihs.rest.tindakan-to-loinc',
            28 => 'kemkes\\ihs.rest.parameter-hasil-to-loinc',
            29 => 'kemkes\\ihs.rest.snomed-ct',
            30 => 'kemkes-ihs.rpc.allergy-intolerance',
        ],
    ],
    'api-tools-rpc' => [
        'Kemkes\\IHS\\V1\\Rpc\\Organization\\Controller' => [
            'service_name' => 'Organization',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.organization',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Location\\Controller' => [
            'service_name' => 'Location',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.location',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Controller' => [
            'service_name' => 'Practitioner',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.practitioner',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Patient\\Controller' => [
            'service_name' => 'Patient',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.patient',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Encounter\\Controller' => [
            'service_name' => 'Encounter',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.encounter',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Condition\\Controller' => [
            'service_name' => 'Condition',
            'http_methods' => [
                0 => 'GET',
                1 => 'PUT',
                2 => 'POST',
            ],
            'route_name' => 'kemkes-ihs.rpc.condition',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Observation\\Controller' => [
            'service_name' => 'Observation',
            'http_methods' => [
                0 => 'GET',
                1 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.observation',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Procedure\\Controller' => [
            'service_name' => 'Procedure',
            'http_methods' => [
                0 => 'GET',
                1 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.procedure',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Composition\\Controller' => [
            'service_name' => 'Composition',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.composition',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Medication\\Controller' => [
            'service_name' => 'Medication',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.medication',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\MedicationRequest\\Controller' => [
            'service_name' => 'MedicationRequest',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.medication-request',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Controller' => [
            'service_name' => 'MedicationDispanse',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.medication-dispanse',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\ServiceRequest\\Controller' => [
            'service_name' => 'ServiceRequest',
            'http_methods' => [
                0 => 'GET',
                1 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.service-request',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Specimen\\Controller' => [
            'service_name' => 'Specimen',
            'http_methods' => [
                0 => 'GET',
                1 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.specimen',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Controller' => [
            'service_name' => 'DiagnosticReport',
            'http_methods' => [
                0 => 'GET',
                1 => 'PUT',
            ],
            'route_name' => 'kemkes-ihs.rpc.diagnostic-report',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\Consent\\Controller' => [
            'service_name' => 'Consent',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.consent',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\KnowYourCustomer\\Controller' => [
            'service_name' => 'KnowYourCustomer',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.know-your-customer',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\KFA\\Controller' => [
            'service_name' => 'KFA',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.kfa',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\ImagingStudy\\Controller' => [
            'service_name' => 'ImagingStudy',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.imaging-study',
        ],
        'Kemkes\\IHS\\V1\\Rpc\\AllergyIntolerance\\Controller' => [
            'service_name' => 'AllergyIntolerance',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-ihs.rpc.allergy-intolerance',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Kemkes\\IHS\\V1\\Rpc\\Organization\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Location\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Patient\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Encounter\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Condition\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Observation\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Procedure\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Composition\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Medication\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\MedicationRequest\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\ServiceRequest\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Specimen\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\Consent\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\KnowYourCustomer\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\POA\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\POV\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\BZA\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\BarangToPoaPov\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\BarangToBza\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\CodeReference\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\TypeCodeReference\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\KFA\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\Sinkronisasi\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\ImagingStudy\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\Loinc\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\TindakanToLoinc\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\ParameterHasilToLoinc\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rest\\SnomedCt\\Controller' => 'Json',
            'Kemkes\\IHS\\V1\\Rpc\\AllergyIntolerance\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Kemkes\\IHS\\V1\\Rpc\\Organization\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Location\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Patient\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Encounter\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Condition\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Observation\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Procedure\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Composition\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Medication\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\MedicationRequest\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\ServiceRequest\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Specimen\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Consent\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\KnowYourCustomer\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\POA\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\POV\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\BZA\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\BarangToPoaPov\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\BarangToBza\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\CodeReference\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\TypeCodeReference\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\KFA\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\Sinkronisasi\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\ImagingStudy\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\Loinc\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\TindakanToLoinc\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\ParameterHasilToLoinc\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\SnomedCt\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\AllergyIntolerance\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'Kemkes\\IHS\\V1\\Rpc\\Organization\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Location\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Practitioner\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Patient\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Encounter\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Condition\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Observation\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Procedure\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Composition\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Medication\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\MedicationRequest\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\MedicationDispanse\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\ServiceRequest\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Specimen\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\DiagnosticReport\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\Consent\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\KnowYourCustomer\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\POA\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\POV\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\BZA\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\BarangToPoaPov\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\BarangToBza\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\CodeReference\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\TypeCodeReference\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\KFA\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\Sinkronisasi\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\ImagingStudy\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\Loinc\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\TindakanToLoinc\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\ParameterHasilToLoinc\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rest\\SnomedCt\\Controller' => [
                0 => 'application/vnd.kemkes\\ihs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\IHS\\V1\\Rpc\\AllergyIntolerance\\Controller' => [
                0 => 'application/vnd.kemkes-ihs.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'service_manager' => [
        'factories' => [
            \Kemkes\IHS\V1\Rest\POA\POAResource::class => \Kemkes\IHS\V1\Rest\POA\POAResourceFactory::class,
            \Kemkes\IHS\V1\Rest\POV\POVResource::class => \Kemkes\IHS\V1\Rest\POV\POVResourceFactory::class,
            \Kemkes\IHS\V1\Rest\BZA\BZAResource::class => \Kemkes\IHS\V1\Rest\BZA\BZAResourceFactory::class,
            \Kemkes\IHS\V1\Rest\BarangToPoaPov\BarangToPoaPovResource::class => \Kemkes\IHS\V1\Rest\BarangToPoaPov\BarangToPoaPovResourceFactory::class,
            \Kemkes\IHS\V1\Rest\BarangToBza\BarangToBzaResource::class => \Kemkes\IHS\V1\Rest\BarangToBza\BarangToBzaResourceFactory::class,
            \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceResource::class => \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceResourceFactory::class,
            \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceResource::class => \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceResourceFactory::class,
            \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiResource::class => \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiResourceFactory::class,
            \Kemkes\IHS\V1\Rest\Loinc\LoincResource::class => \Kemkes\IHS\V1\Rest\Loinc\LoincResourceFactory::class,
            \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincResource::class => \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincResourceFactory::class,
            \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincResource::class => \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincResourceFactory::class,
            \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtResource::class => \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'Kemkes\\IHS\\V1\\Rest\\POA\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\POA\POAResource::class,
            'route_name' => 'kemkes\\ihs.rest.poa',
            'route_identifier_name' => 'id',
            'collection_name' => 'EURY',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'pov',
                1 => 'status',
                2 => 'id',
                3 => 'limit',
                4 => 'start',
                5 => 'display',
                6 => 'query',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\POA\POAEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\POA\POACollection::class,
            'service_name' => 'POA',
        ],
        'Kemkes\\IHS\\V1\\Rest\\POV\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\POV\POVResource::class,
            'route_name' => 'kemkes\\ihs.rest.pov',
            'route_identifier_name' => 'id',
            'collection_name' => 'pov',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'display',
                1 => 'status',
                2 => 'id',
                3 => 'start',
                4 => 'limit',
                5 => 'query',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\POV\POVEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\POV\POVCollection::class,
            'service_name' => 'POV',
        ],
        'Kemkes\\IHS\\V1\\Rest\\BZA\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\BZA\BZAResource::class,
            'route_name' => 'kemkes\\ihs.rest.bza',
            'route_identifier_name' => 'id',
            'collection_name' => 'bza',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'status',
                1 => 'limit',
                2 => 'start',
                3 => 'display',
                4 => 'query',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\BZA\BZAEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\BZA\BZACollection::class,
            'service_name' => 'BZA',
        ],
        'Kemkes\\IHS\\V1\\Rest\\BarangToPoaPov\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\BarangToPoaPov\BarangToPoaPovResource::class,
            'route_name' => 'kemkes\\ihs.rest.barang-to-poa-pov',
            'route_identifier_name' => 'id',
            'collection_name' => 'barang_to_poa_pov',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'BARANG',
                1 => 'KODE_POA',
                2 => 'KODE_POV',
                3 => 'RUTE_OBAT',
                4 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\BarangToPoaPov\BarangToPoaPovEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\BarangToPoaPov\BarangToPoaPovCollection::class,
            'service_name' => 'BarangToPoaPov',
        ],
        'Kemkes\\IHS\\V1\\Rest\\BarangToBza\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\BarangToBza\BarangToBzaResource::class,
            'route_name' => 'kemkes\\ihs.rest.barang-to-bza',
            'route_identifier_name' => 'id',
            'collection_name' => 'barang_to_bza',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'BARANG',
                1 => 'KODE_BZA',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\BarangToBza\BarangToBzaEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\BarangToBza\BarangToBzaCollection::class,
            'service_name' => 'BarangToBza',
        ],
        'Kemkes\\IHS\\V1\\Rest\\CodeReference\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceResource::class,
            'route_name' => 'kemkes\\ihs.rest.code-reference',
            'route_identifier_name' => 'id',
            'collection_name' => 'code_reference',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'resources',
                1 => 'status',
                2 => 'entity',
                3 => 'start',
                4 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceCollection::class,
            'service_name' => 'CodeReference',
        ],
        'Kemkes\\IHS\\V1\\Rest\\TypeCodeReference\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceResource::class,
            'route_name' => 'kemkes\\ihs.rest.type-code-reference',
            'route_identifier_name' => 'id',
            'collection_name' => 'type_code_reference',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'type',
                1 => 'status',
                2 => 'display',
                3 => 'code',
                4 => 'start',
                5 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceCollection::class,
            'service_name' => 'TypeCodeReference',
        ],
        'Kemkes\\IHS\\V1\\Rest\\Sinkronisasi\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiResource::class,
            'route_name' => 'kemkes\\ihs.rest.sinkronisasi',
            'route_identifier_name' => 'sinkronisasi_id',
            'collection_name' => 'sinkronisasi',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'start',
                1 => 'limit',
                2 => 'ID',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiCollection::class,
            'service_name' => 'Sinkronisasi',
        ],
        'Kemkes\\IHS\\V1\\Rest\\Loinc\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\Loinc\LoincResource::class,
            'route_name' => 'kemkes\\ihs.rest.loinc',
            'route_identifier_name' => 'id',
            'collection_name' => 'loinc',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'kategori_pemeriksaan',
                1 => 'code',
                2 => 'nama_pemeriksaan',
                3 => 'query',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\Loinc\LoincEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\Loinc\LoincCollection::class,
            'service_name' => 'Loinc',
        ],
        'Kemkes\\IHS\\V1\\Rest\\TindakanToLoinc\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincResource::class,
            'route_name' => 'kemkes\\ihs.rest.tindakan-to-loinc',
            'route_identifier_name' => 'id',
            'collection_name' => 'tindakan_to_loinc',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'TINDAKAN',
                1 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincCollection::class,
            'service_name' => 'TindakanToLoinc',
        ],
        'Kemkes\\IHS\\V1\\Rest\\ParameterHasilToLoinc\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincResource::class,
            'route_name' => 'kemkes\\ihs.rest.parameter-hasil-to-loinc',
            'route_identifier_name' => 'id',
            'collection_name' => 'parameter_hasil_to_loinc',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'PARAMETER_HASIL',
                1 => 'TINDAKAN',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincCollection::class,
            'service_name' => 'ParameterHasilToLoinc',
        ],
        'Kemkes\\IHS\\V1\\Rest\\SnomedCt\\Controller' => [
            'listener' => \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtResource::class,
            'route_name' => 'kemkes\\ihs.rest.snomed-ct',
            'route_identifier_name' => 'snomed_ct_id',
            'collection_name' => 'snomed_ct',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'collection_query_whitelist' => [
                0 => 'conceptId',
                1 => 'term',
                2 => 'active',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtEntity::class,
            'collection_class' => \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtCollection::class,
            'service_name' => 'SnomedCt',
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.sinkronisasi',
                'route_identifier_name' => 'sinkronisasi_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\Sinkronisasi\SinkronisasiCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.sinkronisasi',
                'route_identifier_name' => 'sinkronisasi_id',
                'is_collection' => true,
            ],
            \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.code-reference',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\CodeReference\CodeReferenceCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.code-reference',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.type-code-reference',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\TypeCodeReference\TypeCodeReferenceCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.type-code-reference',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Kemkes\IHS\V1\Rest\Loinc\LoincEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'kemkes\\ihs.rest.loinc',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\Loinc\LoincCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'kemkes\\ihs.rest.loinc',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincEntity::class => [
                'entity_identifier_name' => 'TINDAKAN',
                'route_name' => 'kemkes\\ihs.rest.tindakan-to-loinc',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\TindakanToLoinc\TindakanToLoincCollection::class => [
                'entity_identifier_name' => 'TINDAKAN',
                'route_name' => 'kemkes\\ihs.rest.tindakan-to-loinc',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincEntity::class => [
                'entity_identifier_name' => 'PARAMETER_HASIL',
                'route_name' => 'kemkes\\ihs.rest.parameter-hasil-to-loinc',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\ParameterHasilToLoinc\ParameterHasilToLoincCollection::class => [
                'entity_identifier_name' => 'PARAMETER_HASIL',
                'route_name' => 'kemkes\\ihs.rest.parameter-hasil-to-loinc',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.snomed-ct',
                'route_identifier_name' => 'snomed_ct_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\IHS\V1\Rest\SnomedCt\SnomedCtCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes\\ihs.rest.snomed-ct',
                'route_identifier_name' => 'snomed_ct_id',
                'is_collection' => true,
            ],
        ],
    ],
];
