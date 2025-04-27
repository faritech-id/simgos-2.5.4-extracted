<?php
return [
    'router' => [
        'routes' => [
            'informasi.rest.infromasi-ruang-kamar-tidur' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/informasi/ruangkamartidur[/:id]',
                    'defaults' => [
                        'controller' => 'Informasi\\V1\\Rest\\InfromasiRuangKamarTidur\\Controller',
                    ],
                ],
            ],
            'informasi.rest.monitoring-sikepo' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/informasi/monitoringsikepo[/:monitoring_sikepo_id]',
                    'defaults' => [
                        'controller' => 'Informasi\\V1\\Rest\\MonitoringSikepo\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'informasi.rest.infromasi-ruang-kamar-tidur',
            1 => 'informasi.rest.monitoring-sikepo',
        ],
    ],
    'service_manager' => [
        'factories' => [
            \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurResource::class => \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurResourceFactory::class,
            \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoResource::class => \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'Informasi\\V1\\Rest\\InfromasiRuangKamarTidur\\Controller' => [
            'listener' => \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurResource::class,
            'route_name' => 'informasi.rest.infromasi-ruang-kamar-tidur',
            'route_identifier_name' => 'id',
            'collection_name' => 'infromasi_ruang_kamar_tidur',
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
                1 => 'PASIEN',
                2 => 'RUANGAN',
                3 => 'KAMAR',
                4 => 'KELAS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurEntity::class,
            'collection_class' => \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurCollection::class,
            'service_name' => 'InfromasiRuangKamarTidur',
        ],
        'Informasi\\V1\\Rest\\MonitoringSikepo\\Controller' => [
            'listener' => \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoResource::class,
            'route_name' => 'informasi.rest.monitoring-sikepo',
            'route_identifier_name' => 'monitoring_sikepo_id',
            'collection_name' => 'monitoring_sikepo',
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
                0 => 'TANGGAL',
                1 => 'STATUSGROUPING',
                2 => 'CARAKELUAR',
                3 => 'RUANGAN',
                4 => 'LAPORAN',
                5 => 'CARABAYAR',
                6 => 'DOKTER',
                7 => 'STATUSLOS',
                8 => 'STATUSTARIF',
                9 => 'RENCANAPULANG',
                10 => 'PCARI',
                11 => 'MONITORING',
                12 => 'KASUS_SEJENIS',
                13 => 'PCODE_CBG',
                14 => 'page',
                15 => 'PSEVERITY',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoEntity::class,
            'collection_class' => \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoCollection::class,
            'service_name' => 'MonitoringSikepo',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Informasi\\V1\\Rest\\InfromasiRuangKamarTidur\\Controller' => 'Json',
            'Informasi\\V1\\Rest\\MonitoringSikepo\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Informasi\\V1\\Rest\\InfromasiRuangKamarTidur\\Controller' => [
                0 => 'application/vnd.informasi.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Informasi\\V1\\Rest\\MonitoringSikepo\\Controller' => [
                0 => 'application/vnd.informasi.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'Informasi\\V1\\Rest\\InfromasiRuangKamarTidur\\Controller' => [
                0 => 'application/vnd.informasi.v1+json',
                1 => 'application/json',
            ],
            'Informasi\\V1\\Rest\\MonitoringSikepo\\Controller' => [
                0 => 'application/vnd.informasi.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'informasi.rest.infromasi-ruang-kamar-tidur',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \Informasi\V1\Rest\InfromasiRuangKamarTidur\InfromasiRuangKamarTidurCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'informasi.rest.infromasi-ruang-kamar-tidur',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'informasi.rest.monitoring-sikepo',
                'route_identifier_name' => 'monitoring_sikepo_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Informasi\V1\Rest\MonitoringSikepo\MonitoringSikepoCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'informasi.rest.monitoring-sikepo',
                'route_identifier_name' => 'monitoring_sikepo_id',
                'is_collection' => true,
            ],
        ],
    ],
];
