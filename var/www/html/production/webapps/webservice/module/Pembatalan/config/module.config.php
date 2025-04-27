<?php
return [
    'router' => [
        'routes' => [
            'pembatalan.rest.pembatalan-kunjungan' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pembatalan/pembatalankunjungan[/:id]',
                    'defaults' => [
                        'controller' => 'Pembatalan\\V1\\Rest\\PembatalanKunjungan\\Controller',
                    ],
                ],
            ],
            'pembatalan.rest.pembatalan-retur' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pembatalan-retur[/:pembatalan_retur_id]',
                    'defaults' => [
                        'controller' => 'Pembatalan\\V1\\Rest\\PembatalanRetur\\Controller',
                    ],
                ],
            ],
            'pembatalan.rest.final-hasil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pembatalan/final-hasil[/:final_hasil_id]',
                    'defaults' => [
                        'controller' => 'Pembatalan\\V1\\Rest\\FinalHasil\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'pembatalan.rest.pembatalan-kunjungan',
            1 => 'pembatalan.rest.pembatalan-retur',
            2 => 'pembatalan.rest.final-hasil',
        ],
    ],
    'service_manager' => [
        'factories' => [
            \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganResource::class => \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganResourceFactory::class,
            \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturResource::class => \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturResourceFactory::class,
            \Pembatalan\V1\Rest\FinalHasil\FinalHasilResource::class => \Pembatalan\V1\Rest\FinalHasil\FinalHasilResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'Pembatalan\\V1\\Rest\\PembatalanKunjungan\\Controller' => [
            'listener' => \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganResource::class,
            'route_name' => 'pembatalan.rest.pembatalan-kunjungan',
            'route_identifier_name' => 'id',
            'collection_name' => 'pembatalan_kunjungan',
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
                0 => 'KUNJUNGAN',
                1 => 'JENIS',
                2 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganEntity::class,
            'collection_class' => \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganCollection::class,
            'service_name' => 'PembatalanKunjungan',
        ],
        'Pembatalan\\V1\\Rest\\PembatalanRetur\\Controller' => [
            'listener' => \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturResource::class,
            'route_name' => 'pembatalan.rest.pembatalan-retur',
            'route_identifier_name' => 'pembatalan_retur_id',
            'collection_name' => 'pembatalan_retur',
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
            'collection_query_whitelist' => [],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturEntity::class,
            'collection_class' => \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturCollection::class,
            'service_name' => 'PembatalanRetur',
        ],
        'Pembatalan\\V1\\Rest\\FinalHasil\\Controller' => [
            'listener' => \Pembatalan\V1\Rest\FinalHasil\FinalHasilResource::class,
            'route_name' => 'pembatalan.rest.final-hasil',
            'route_identifier_name' => 'final_hasil_id',
            'collection_name' => 'final_hasil',
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
                0 => 'KUNJUNGAN',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Pembatalan\V1\Rest\FinalHasil\FinalHasilEntity::class,
            'collection_class' => \Pembatalan\V1\Rest\FinalHasil\FinalHasilCollection::class,
            'service_name' => 'FinalHasil',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Pembatalan\\V1\\Rest\\PembatalanKunjungan\\Controller' => 'Json',
            'Pembatalan\\V1\\Rest\\PembatalanRetur\\Controller' => 'HalJson',
            'Pembatalan\\V1\\Rest\\FinalHasil\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Pembatalan\\V1\\Rest\\PembatalanKunjungan\\Controller' => [
                0 => 'application/vnd.pembatalan.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Pembatalan\\V1\\Rest\\PembatalanRetur\\Controller' => [
                0 => 'application/vnd.pembatalan.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Pembatalan\\V1\\Rest\\FinalHasil\\Controller' => [
                0 => 'application/vnd.pembatalan.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'Pembatalan\\V1\\Rest\\PembatalanKunjungan\\Controller' => [
                0 => 'application/vnd.pembatalan.v1+json',
                1 => 'application/json',
            ],
            'Pembatalan\\V1\\Rest\\PembatalanRetur\\Controller' => [
                0 => 'application/vnd.pembatalan.v1+json',
                1 => 'application/json',
            ],
            'Pembatalan\\V1\\Rest\\FinalHasil\\Controller' => [
                0 => 'application/vnd.pembatalan.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'pembatalan.rest.pembatalan-kunjungan',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydratore',
            ],
            \Pembatalan\V1\Rest\PembatalanKunjungan\PembatalanKunjunganCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'pembatalan.rest.pembatalan-kunjungan',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pembatalan.rest.pembatalan-retur',
                'route_identifier_name' => 'pembatalan_retur_id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydratore',
            ],
            \Pembatalan\V1\Rest\PembatalanRetur\PembatalanReturCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pembatalan.rest.pembatalan-retur',
                'route_identifier_name' => 'pembatalan_retur_id',
                'is_collection' => true,
            ],
            \Pembatalan\V1\Rest\FinalHasil\FinalHasilEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pembatalan.rest.final-hasil',
                'route_identifier_name' => 'final_hasil_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Pembatalan\V1\Rest\FinalHasil\FinalHasilCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'pembatalan.rest.final-hasil',
                'route_identifier_name' => 'final_hasil_id',
                'is_collection' => true,
            ],
        ],
    ],
];
