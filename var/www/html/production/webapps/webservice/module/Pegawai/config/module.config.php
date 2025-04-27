<?php
return [
    'service_manager' => [
        'factories' => [
            \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasResource::class => \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasResourceFactory::class,
            \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiResource::class => \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiResourceFactory::class,
            \Pegawai\V1\Rest\StrSip\StrSipResource::class => \Pegawai\V1\Rest\StrSip\StrSipResourceFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'pegawai.rest.kartu-identitas' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pegawai/kartuidentitas[/:id]',
                    'defaults' => [
                        'controller' => 'Pegawai\\V1\\Rest\\KartuIdentitas\\Controller',
                    ],
                ],
            ],
            'pegawai.rest.kontak-pegawai' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pegawai/kontakpegawai[/:id]',
                    'defaults' => [
                        'controller' => 'Pegawai\\V1\\Rest\\KontakPegawai\\Controller',
                    ],
                ],
            ],
            'pegawai.rest.str-sip' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pegawai/str-sip[/:str_sip_id]',
                    'defaults' => [
                        'controller' => 'Pegawai\\V1\\Rest\\StrSip\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            1 => 'pegawai.rest.kartu-identitas',
            0 => 'pegawai.rest.kontak-pegawai',
            2 => 'pegawai.rest.str-sip',
        ],
    ],
    'api-tools-rest' => [
        'Pegawai\\V1\\Rest\\KartuIdentitas\\Controller' => [
            'listener' => \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasResource::class,
            'route_name' => 'pegawai.rest.kartu-identitas',
            'route_identifier_name' => 'id',
            'collection_name' => 'kartu_identitas',
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
                0 => 'JENIS',
                1 => 'NIP',
                2 => 'NOMOR',
                3 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasEntity::class,
            'collection_class' => \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasCollection::class,
            'service_name' => 'KartuIdentitas',
        ],
        'Pegawai\\V1\\Rest\\KontakPegawai\\Controller' => [
            'listener' => \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiResource::class,
            'route_name' => 'pegawai.rest.kontak-pegawai',
            'route_identifier_name' => 'id',
            'collection_name' => 'kontak_pegawai',
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
                0 => 'NIP',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiEntity::class,
            'collection_class' => \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiCollection::class,
            'service_name' => 'KontakPegawai',
        ],
        'Pegawai\\V1\\Rest\\StrSip\\Controller' => [
            'listener' => \Pegawai\V1\Rest\StrSip\StrSipResource::class,
            'route_name' => 'pegawai.rest.str-sip',
            'route_identifier_name' => 'str_sip_id',
            'collection_name' => 'str_sip',
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
                0 => 'NIP',
                1 => 'JENIS',
                2 => 'STATUS',
                3 => 'SHOW_FILE',
                4 => 'IDX',
                5 => 'start',
                6 => 'limit',
                7 => 'QUERY',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Pegawai\V1\Rest\StrSip\StrSipEntity::class,
            'collection_class' => \Pegawai\V1\Rest\StrSip\StrSipCollection::class,
            'service_name' => 'StrSip',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Pegawai\\V1\\Rest\\KartuIdentitas\\Controller' => 'Json',
            'Pegawai\\V1\\Rest\\KontakPegawai\\Controller' => 'Json',
            'Pegawai\\V1\\Rest\\StrSip\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Pegawai\\V1\\Rest\\KartuIdentitas\\Controller' => [
                0 => 'application/vnd.pegawai.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Pegawai\\V1\\Rest\\KontakPegawai\\Controller' => [
                0 => 'application/vnd.pegawai.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Pegawai\\V1\\Rest\\StrSip\\Controller' => [
                0 => 'application/vnd.pegawai.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'Pegawai\\V1\\Rest\\KartuIdentitas\\Controller' => [
                0 => 'application/vnd.pegawai.v1+json',
                1 => 'application/json',
            ],
            'Pegawai\\V1\\Rest\\KontakPegawai\\Controller' => [
                0 => 'application/vnd.pegawai.v1+json',
                1 => 'application/json',
            ],
            'Pegawai\\V1\\Rest\\StrSip\\Controller' => [
                0 => 'application/vnd.pegawai.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pegawai.rest.kartu-identitas',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Pegawai\V1\Rest\KartuIdentitas\KartuIdentitasCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pegawai.rest.kartu-identitas',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pegawai.rest.kontak-pegawai',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Pegawai\V1\Rest\KontakPegawai\KontakPegawaiCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pegawai.rest.kontak-pegawai',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Pegawai\V1\Rest\StrSip\StrSipEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pegawai.rest.str-sip',
                'route_identifier_name' => 'str_sip_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Pegawai\V1\Rest\StrSip\StrSipCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pegawai.rest.str-sip',
                'route_identifier_name' => 'str_sip_id',
                'is_collection' => true,
            ],
        ],
    ],
];
