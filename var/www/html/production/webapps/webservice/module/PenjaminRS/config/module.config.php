<?php
return [
    'service_manager' => [
        'factories' => [
            \PenjaminRS\V1\Rest\Dpjp\DpjpResource::class => \PenjaminRS\V1\Rest\Dpjp\DpjpResourceFactory::class,
            \PenjaminRS\V1\Rest\Drivers\DriversResource::class => \PenjaminRS\V1\Rest\Drivers\DriversResourceFactory::class,
            \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarResource::class => \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarResourceFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'penjamin-rs.rest.dpjp' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/penjamin-rs/dpjp[/:id]',
                    'defaults' => [
                        'controller' => 'PenjaminRS\\V1\\Rest\\Dpjp\\Controller',
                    ],
                ],
            ],
            'penjamin-rs.rest.drivers' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/penjamin-rs/drivers[/:drivers_id]',
                    'defaults' => [
                        'controller' => 'PenjaminRS\\V1\\Rest\\Drivers\\Controller',
                    ],
                ],
            ],
            'penjamin-rs.rest.cara-keluar' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/penjamin-rs/cara-keluar[/:cara_keluar_id]',
                    'defaults' => [
                        'controller' => 'PenjaminRS\\V1\\Rest\\CaraKeluar\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'penjamin-rs.rest.dpjp',
            1 => 'penjamin-rs.rest.drivers',
            2 => 'penjamin-rs.rest.cara-keluar',
        ],
    ],
    'api-tools-rest' => [
        'PenjaminRS\\V1\\Rest\\Dpjp\\Controller' => [
            'listener' => \PenjaminRS\V1\Rest\Dpjp\DpjpResource::class,
            'route_name' => 'penjamin-rs.rest.dpjp',
            'route_identifier_name' => 'id',
            'collection_name' => 'dpjp',
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
                0 => 'ID',
                1 => 'PENJAMIN',
                2 => 'STATUS',
                3 => 'LOCAL',
                4 => 'DPJP_RS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \PenjaminRS\V1\Rest\Dpjp\DpjpEntity::class,
            'collection_class' => \PenjaminRS\V1\Rest\Dpjp\DpjpCollection::class,
            'service_name' => 'dpjp',
        ],
        'PenjaminRS\\V1\\Rest\\Drivers\\Controller' => [
            'listener' => \PenjaminRS\V1\Rest\Drivers\DriversResource::class,
            'route_name' => 'penjamin-rs.rest.drivers',
            'route_identifier_name' => 'drivers_id',
            'collection_name' => 'drivers',
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
                0 => 'JENIS_DRIVER_ID',
                1 => 'JENIS_PENJAMIN_ID',
                2 => 'start',
                3 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \PenjaminRS\V1\Rest\Drivers\DriversEntity::class,
            'collection_class' => \PenjaminRS\V1\Rest\Drivers\DriversCollection::class,
            'service_name' => 'Drivers',
        ],
        'PenjaminRS\\V1\\Rest\\CaraKeluar\\Controller' => [
            'listener' => \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarResource::class,
            'route_name' => 'penjamin-rs.rest.cara-keluar',
            'route_identifier_name' => 'cara_keluar_id',
            'collection_name' => 'cara_keluar',
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
                0 => 'PENJAMIN',
                1 => 'STATUS',
                2 => 'KODE_RS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarEntity::class,
            'collection_class' => \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarCollection::class,
            'service_name' => 'CaraKeluar',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'PenjaminRS\\V1\\Rest\\Dpjp\\Controller' => 'Json',
            'PenjaminRS\\V1\\Rest\\Drivers\\Controller' => 'Json',
            'PenjaminRS\\V1\\Rest\\CaraKeluar\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'PenjaminRS\\V1\\Rest\\Dpjp\\Controller' => [
                0 => 'application/vnd.penjamin-rs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'PenjaminRS\\V1\\Rest\\Drivers\\Controller' => [
                0 => 'application/vnd.penjamin-rs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'PenjaminRS\\V1\\Rest\\CaraKeluar\\Controller' => [
                0 => 'application/vnd.penjamin-rs.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'PenjaminRS\\V1\\Rest\\Dpjp\\Controller' => [
                0 => 'application/vnd.penjamin-rs.v1+json',
                1 => 'application/json',
            ],
            'PenjaminRS\\V1\\Rest\\Drivers\\Controller' => [
                0 => 'application/vnd.penjamin-rs.v1+json',
                1 => 'application/json',
            ],
            'PenjaminRS\\V1\\Rest\\CaraKeluar\\Controller' => [
                0 => 'application/vnd.penjamin-rs.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \PenjaminRS\V1\Rest\Dpjp\DpjpEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'penjamin-rs.rest.dpjp',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \PenjaminRS\V1\Rest\Dpjp\DpjpCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'penjamin-rs.rest.dpjp',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \PenjaminRS\V1\Rest\Drivers\DriversEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'penjamin-rs.rest.drivers',
                'route_identifier_name' => 'drivers_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \PenjaminRS\V1\Rest\Drivers\DriversCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'penjamin-rs.rest.drivers',
                'route_identifier_name' => 'drivers_id',
                'is_collection' => true,
            ],
            \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'penjamin-rs.rest.cara-keluar',
                'route_identifier_name' => 'cara_keluar_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \PenjaminRS\V1\Rest\CaraKeluar\CaraKeluarCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'penjamin-rs.rest.cara-keluar',
                'route_identifier_name' => 'cara_keluar_id',
                'is_collection' => true,
            ],
        ],
    ],
];
