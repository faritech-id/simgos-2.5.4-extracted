<?php
return [
    'controllers' => [
        'factories' => [
            'BerkasKlaim\\V1\\Rpc\\Berkas\\Controller' => \BerkasKlaim\V1\Rpc\Berkas\BerkasControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'berkas-klaim.rpc.berkas' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkas-klaim[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rpc\\Berkas\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.obat-farmasi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/obatfarmasi[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\ObatFarmasi\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.obat-farmasi-detil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/obatfarmasidetil[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\ObatFarmasiDetil\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.radiologi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/radiologi[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\Radiologi\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.radiologi-detil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/radiologidetil[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\RadiologiDetil\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.patologi-anatomi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/patologianatomi[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\PatologiAnatomi\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.patologi-anatomi-detil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/patologianatomidetil[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\PatologiAnatomiDetil\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.lab-klinik' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/labklinik[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\LabKlinik\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.lab-klinik-detil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/labklinikdetil[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\LabKlinikDetil\\Controller',
                    ],
                ],
            ],
            'berkas-klaim.rest.dokumen-pendukung' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/berkasklaim/dokumenpendukung[/:id]',
                    'defaults' => [
                        'controller' => 'BerkasKlaim\\V1\\Rest\\DokumenPendukung\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'berkas-klaim.rpc.berkas',
            1 => 'berkas-klaim.rest.obat-farmasi',
            2 => 'berkas-klaim.rest.obat-farmasi-detil',
            3 => 'berkas-klaim.rest.radiologi',
            4 => 'berkas-klaim.rest.radiologi-detil',
            5 => 'berkas-klaim.rest.patologi-anatomi',
            6 => 'berkas-klaim.rest.patologi-anatomi-detil',
            7 => 'berkas-klaim.rest.lab-klinik',
            8 => 'berkas-klaim.rest.lab-klinik-detil',
            9 => 'berkas-klaim.rest.dokumen-pendukung',
        ],
    ],
    'api-tools-rpc' => [
        'BerkasKlaim\\V1\\Rpc\\Berkas\\Controller' => [
            'service_name' => 'Berkas',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'berkas-klaim.rpc.berkas',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'BerkasKlaim\\V1\\Rpc\\Berkas\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\ObatFarmasi\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\ObatFarmasiDetil\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\Radiologi\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\RadiologiDetil\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\PatologiAnatomi\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\PatologiAnatomiDetil\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\LabKlinik\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\LabKlinikDetil\\Controller' => 'Json',
            'BerkasKlaim\\V1\\Rest\\DokumenPendukung\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'BerkasKlaim\\V1\\Rpc\\Berkas\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BerkasKlaim\\V1\\Rest\\ObatFarmasi\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\ObatFarmasiDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\Radiologi\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\RadiologiDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\PatologiAnatomi\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\PatologiAnatomiDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\LabKlinik\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\LabKlinikDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\DokumenPendukung\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'BerkasKlaim\\V1\\Rpc\\Berkas\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\ObatFarmasi\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\ObatFarmasiDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\Radiologi\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\RadiologiDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\PatologiAnatomi\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\PatologiAnatomiDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\LabKlinik\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\LabKlinikDetil\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
            'BerkasKlaim\\V1\\Rest\\DokumenPendukung\\Controller' => [
                0 => 'application/vnd.berkas-klaim.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'service_manager' => [
        'factories' => [
            \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiResource::class => \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiResourceFactory::class,
            \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilResource::class => \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilResourceFactory::class,
            \BerkasKlaim\V1\Rest\Radiologi\RadiologiResource::class => \BerkasKlaim\V1\Rest\Radiologi\RadiologiResourceFactory::class,
            \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilResource::class => \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilResourceFactory::class,
            \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiResource::class => \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiResourceFactory::class,
            \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilResource::class => \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilResourceFactory::class,
            \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikResource::class => \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikResourceFactory::class,
            \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilResource::class => \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilResourceFactory::class,
            \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungResource::class => \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'BerkasKlaim\\V1\\Rest\\ObatFarmasi\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiResource::class,
            'route_name' => 'berkas-klaim.rest.obat-farmasi',
            'route_identifier_name' => 'id',
            'collection_name' => 'obat_farmasi',
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
                0 => 'PENDAFTARAN',
                1 => 'NOSEP',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiCollection::class,
            'service_name' => 'ObatFarmasi',
        ],
        'BerkasKlaim\\V1\\Rest\\ObatFarmasiDetil\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilResource::class,
            'route_name' => 'berkas-klaim.rest.obat-farmasi-detil',
            'route_identifier_name' => 'id',
            'collection_name' => 'obat_farmasi_detil',
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
                0 => 'OBAT_FARMASI',
                1 => 'KUNJUNGAN',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilCollection::class,
            'service_name' => 'ObatFarmasiDetil',
        ],
        'BerkasKlaim\\V1\\Rest\\Radiologi\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\Radiologi\RadiologiResource::class,
            'route_name' => 'berkas-klaim.rest.radiologi',
            'route_identifier_name' => 'id',
            'collection_name' => 'radiologi',
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
                0 => 'NORM',
                1 => 'NOSEP',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\Radiologi\RadiologiEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\Radiologi\RadiologiCollection::class,
            'service_name' => 'Radiologi',
        ],
        'BerkasKlaim\\V1\\Rest\\RadiologiDetil\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilResource::class,
            'route_name' => 'berkas-klaim.rest.radiologi-detil',
            'route_identifier_name' => 'id',
            'collection_name' => 'radiologi_detil',
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
                0 => 'STATUS',
                1 => 'RADIOLOGI',
                2 => 'HASIL_RAD',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilCollection::class,
            'service_name' => 'RadiologiDetil',
        ],
        'BerkasKlaim\\V1\\Rest\\PatologiAnatomi\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiResource::class,
            'route_name' => 'berkas-klaim.rest.patologi-anatomi',
            'route_identifier_name' => 'id',
            'collection_name' => 'patologi_anatomi',
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
                0 => 'NORM',
                1 => 'NOSEP',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiCollection::class,
            'service_name' => 'PatologiAnatomi',
        ],
        'BerkasKlaim\\V1\\Rest\\PatologiAnatomiDetil\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilResource::class,
            'route_name' => 'berkas-klaim.rest.patologi-anatomi-detil',
            'route_identifier_name' => 'id',
            'collection_name' => 'patologi_anatomi_detil',
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
                0 => 'PATOLOGI_ANATOMI',
                1 => 'HASIL_PA',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilCollection::class,
            'service_name' => 'PatologiAnatomiDetil',
        ],
        'BerkasKlaim\\V1\\Rest\\LabKlinik\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikResource::class,
            'route_name' => 'berkas-klaim.rest.lab-klinik',
            'route_identifier_name' => 'id',
            'collection_name' => 'lab_klinik',
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
                0 => 'NORM',
                1 => 'NOSEP',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikCollection::class,
            'service_name' => 'LabKlinik',
        ],
        'BerkasKlaim\\V1\\Rest\\LabKlinikDetil\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilResource::class,
            'route_name' => 'berkas-klaim.rest.lab-klinik-detil',
            'route_identifier_name' => 'id',
            'collection_name' => 'lab_klinik_detil',
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
                0 => 'LAB_KLINIK',
                1 => 'HASIL_LAB',
                2 => 'STATUS',
                3 => 'GROUP_TINDAKAN_MEDIS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilCollection::class,
            'service_name' => 'LabKlinikDetil',
        ],
        'BerkasKlaim\\V1\\Rest\\DokumenPendukung\\Controller' => [
            'listener' => \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungResource::class,
            'route_name' => 'berkas-klaim.rest.dokumen-pendukung',
            'route_identifier_name' => 'id',
            'collection_name' => 'dokumen_pendukung',
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
                0 => 'STATUS',
                1 => 'BERKAS',
                2 => 'TANGGAL',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungEntity::class,
            'collection_class' => \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungCollection::class,
            'service_name' => 'DokumenPendukung',
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.obat-farmasi',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\ObatFarmasi\ObatFarmasiCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.obat-farmasi',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.obat-farmasi-detil',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\ObatFarmasiDetil\ObatFarmasiDetilCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.obat-farmasi-detil',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\Radiologi\RadiologiEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.radiologi',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\Radiologi\RadiologiCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.radiologi',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.radiologi-detil',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\RadiologiDetil\RadiologiDetilCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.radiologi-detil',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.patologi-anatomi',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\PatologiAnatomi\PatologiAnatomiCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.patologi-anatomi',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.patologi-anatomi-detil',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\PatologiAnatomiDetil\PatologiAnatomiDetilCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.patologi-anatomi-detil',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.lab-klinik',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\LabKlinik\LabKlinikCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.lab-klinik',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.lab-klinik-detil',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\LabKlinikDetil\LabKlinikDetilCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.lab-klinik-detil',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.dokumen-pendukung',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \BerkasKlaim\V1\Rest\DokumenPendukung\DokumenPendukungCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'berkas-klaim.rest.dokumen-pendukung',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
        ],
    ],
];
