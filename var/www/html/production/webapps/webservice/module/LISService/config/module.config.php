<?php
return [
    'controllers' => [
        'factories' => [
            'LISService\\V1\\Rpc\\Service\\Controller' => \LISService\V1\Rpc\Service\ServiceControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'lis-service.rpc.service' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/service[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rpc\\Service\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.hasil-log' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/hasil-log[/:hasil_log_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\HasilLog\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.status-hasil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/status-hasil[/:status_hasil_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\StatusHasil\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.vendor' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/vendor[/:vendor_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\Vendor\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.parameter' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/parameter[/:parameter_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\Parameter\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.mapping-hasil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/mapping-hasil[/:mapping_hasil_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\MappingHasil\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.tanpa-order-config' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/tanpa-order-config[/:tanpa_order_config_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\TanpaOrderConfig\\Controller',
                    ],
                ],
            ],
            'lis-service.rest.prefix-parameter' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/lis/prefix-parameter[/:prefix_parameter_id]',
                    'defaults' => [
                        'controller' => 'LISService\\V1\\Rest\\PrefixParameter\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'lis-service.rpc.service',
            1 => 'lis-service.rest.hasil-log',
            2 => 'lis-service.rest.status-hasil',
            3 => 'lis-service.rest.vendor',
            4 => 'lis-service.rest.parameter',
            5 => 'lis-service.rest.mapping-hasil',
            6 => 'lis-service.rest.tanpa-order-config',
            7 => 'lis-service.rest.prefix-parameter',
        ],
    ],
    'api-tools-rpc' => [
        'LISService\\V1\\Rpc\\Service\\Controller' => [
            'service_name' => 'Service',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'lis-service.rpc.service',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'LISService\\V1\\Rpc\\Service\\Controller' => 'Json',
            'LISService\\V1\\Rest\\HasilLog\\Controller' => 'Json',
            'LISService\\V1\\Rest\\StatusHasil\\Controller' => 'Json',
            'LISService\\V1\\Rest\\Vendor\\Controller' => 'Json',
            'LISService\\V1\\Rest\\Parameter\\Controller' => 'Json',
            'LISService\\V1\\Rest\\MappingHasil\\Controller' => 'Json',
            'LISService\\V1\\Rest\\TanpaOrderConfig\\Controller' => 'Json',
            'LISService\\V1\\Rest\\PrefixParameter\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'LISService\\V1\\Rpc\\Service\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'LISService\\V1\\Rest\\HasilLog\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'LISService\\V1\\Rest\\StatusHasil\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'LISService\\V1\\Rest\\Vendor\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'LISService\\V1\\Rest\\Parameter\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'LISService\\V1\\Rest\\MappingHasil\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'LISService\\V1\\Rest\\TanpaOrderConfig\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'LISService\\V1\\Rest\\PrefixParameter\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'LISService\\V1\\Rpc\\Service\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\HasilLog\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\StatusHasil\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\Vendor\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\Parameter\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\MappingHasil\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\TanpaOrderConfig\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
            'LISService\\V1\\Rest\\PrefixParameter\\Controller' => [
                0 => 'application/vnd.lis-service.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'service_manager' => [
        'factories' => [
            \LISService\V1\Rest\HasilLog\HasilLogResource::class => \LISService\V1\Rest\HasilLog\HasilLogResourceFactory::class,
            \LISService\V1\Rest\StatusHasil\StatusHasilResource::class => \LISService\V1\Rest\StatusHasil\StatusHasilResourceFactory::class,
            \LISService\V1\Rest\Vendor\VendorResource::class => \LISService\V1\Rest\Vendor\VendorResourceFactory::class,
            \LISService\V1\Rest\Parameter\ParameterResource::class => \LISService\V1\Rest\Parameter\ParameterResourceFactory::class,
            \LISService\V1\Rest\MappingHasil\MappingHasilResource::class => \LISService\V1\Rest\MappingHasil\MappingHasilResourceFactory::class,
            \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigResource::class => \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigResourceFactory::class,
            \LISService\V1\Rest\PrefixParameter\PrefixParameterResource::class => \LISService\V1\Rest\PrefixParameter\PrefixParameterResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'LISService\\V1\\Rest\\HasilLog\\Controller' => [
            'listener' => \LISService\V1\Rest\HasilLog\HasilLogResource::class,
            'route_name' => 'lis-service.rest.hasil-log',
            'route_identifier_name' => 'hasil_log_id',
            'collection_name' => 'hasil_log',
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
                1 => 'NAMA',
                2 => 'STATUS',
                3 => 'HIS_NO_LAB',
                4 => 'NOPEN',
                5 => 'VENDOR_LIS',
                6 => 'LIS_TANGGAL',
                7 => 'start',
                8 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \LISService\V1\Rest\HasilLog\HasilLogEntity::class,
            'collection_class' => \LISService\V1\Rest\HasilLog\HasilLogCollection::class,
            'service_name' => 'HasilLog',
        ],
        'LISService\\V1\\Rest\\StatusHasil\\Controller' => [
            'listener' => \LISService\V1\Rest\StatusHasil\StatusHasilResource::class,
            'route_name' => 'lis-service.rest.status-hasil',
            'route_identifier_name' => 'status_hasil_id',
            'collection_name' => 'status_hasil',
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
            'entity_class' => \LISService\V1\Rest\StatusHasil\StatusHasilEntity::class,
            'collection_class' => \LISService\V1\Rest\StatusHasil\StatusHasilCollection::class,
            'service_name' => 'StatusHasil',
        ],
        'LISService\\V1\\Rest\\Vendor\\Controller' => [
            'listener' => \LISService\V1\Rest\Vendor\VendorResource::class,
            'route_name' => 'lis-service.rest.vendor',
            'route_identifier_name' => 'vendor_id',
            'collection_name' => 'vendor',
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
            'entity_class' => \LISService\V1\Rest\Vendor\VendorEntity::class,
            'collection_class' => \LISService\V1\Rest\Vendor\VendorCollection::class,
            'service_name' => 'Vendor',
        ],
        'LISService\\V1\\Rest\\Parameter\\Controller' => [
            'listener' => \LISService\V1\Rest\Parameter\ParameterResource::class,
            'route_name' => 'lis-service.rest.parameter',
            'route_identifier_name' => 'parameter_id',
            'collection_name' => 'parameter',
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
                0 => 'VENDOR_ID',
                1 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \LISService\V1\Rest\Parameter\ParameterEntity::class,
            'collection_class' => \LISService\V1\Rest\Parameter\ParameterCollection::class,
            'service_name' => 'Parameter',
        ],
        'LISService\\V1\\Rest\\MappingHasil\\Controller' => [
            'listener' => \LISService\V1\Rest\MappingHasil\MappingHasilResource::class,
            'route_name' => 'lis-service.rest.mapping-hasil',
            'route_identifier_name' => 'mapping_hasil_id',
            'collection_name' => 'mapping_hasil',
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
                0 => 'VENDOR_LIS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \LISService\V1\Rest\MappingHasil\MappingHasilEntity::class,
            'collection_class' => \LISService\V1\Rest\MappingHasil\MappingHasilCollection::class,
            'service_name' => 'MappingHasil',
        ],
        'LISService\\V1\\Rest\\TanpaOrderConfig\\Controller' => [
            'listener' => \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigResource::class,
            'route_name' => 'lis-service.rest.tanpa-order-config',
            'route_identifier_name' => 'tanpa_order_config_id',
            'collection_name' => 'tanpa_order_config',
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
            'entity_class' => \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigEntity::class,
            'collection_class' => \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigCollection::class,
            'service_name' => 'TanpaOrderConfig',
        ],
        'LISService\\V1\\Rest\\PrefixParameter\\Controller' => [
            'listener' => \LISService\V1\Rest\PrefixParameter\PrefixParameterResource::class,
            'route_name' => 'lis-service.rest.prefix-parameter',
            'route_identifier_name' => 'prefix_parameter_id',
            'collection_name' => 'prefix_parameter',
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
                0 => 'VENDOR_ID',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \LISService\V1\Rest\PrefixParameter\PrefixParameterEntity::class,
            'collection_class' => \LISService\V1\Rest\PrefixParameter\PrefixParameterCollection::class,
            'service_name' => 'PrefixParameter',
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \LISService\V1\Rest\HasilLog\HasilLogEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.hasil-log',
                'route_identifier_name' => 'hasil_log_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\HasilLog\HasilLogCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.hasil-log',
                'route_identifier_name' => 'hasil_log_id',
                'is_collection' => true,
            ],
            \LISService\V1\Rest\StatusHasil\StatusHasilEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.status-hasil',
                'route_identifier_name' => 'status_hasil_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\StatusHasil\StatusHasilCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.status-hasil',
                'route_identifier_name' => 'status_hasil_id',
                'is_collection' => true,
            ],
            \LISService\V1\Rest\Vendor\VendorEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.vendor',
                'route_identifier_name' => 'vendor_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\Vendor\VendorCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.vendor',
                'route_identifier_name' => 'vendor_id',
                'is_collection' => true,
            ],
            \LISService\V1\Rest\Parameter\ParameterEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.parameter',
                'route_identifier_name' => 'parameter_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\Parameter\ParameterCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.parameter',
                'route_identifier_name' => 'parameter_id',
                'is_collection' => true,
            ],
            \LISService\V1\Rest\MappingHasil\MappingHasilEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.mapping-hasil',
                'route_identifier_name' => 'mapping_hasil_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\MappingHasil\MappingHasilCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.mapping-hasil',
                'route_identifier_name' => 'mapping_hasil_id',
                'is_collection' => true,
            ],
            \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.tanpa-order-config',
                'route_identifier_name' => 'tanpa_order_config_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\TanpaOrderConfig\TanpaOrderConfigCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.tanpa-order-config',
                'route_identifier_name' => 'tanpa_order_config_id',
                'is_collection' => true,
            ],
            \LISService\V1\Rest\PrefixParameter\PrefixParameterEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.prefix-parameter',
                'route_identifier_name' => 'prefix_parameter_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \LISService\V1\Rest\PrefixParameter\PrefixParameterCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'lis-service.rest.prefix-parameter',
                'route_identifier_name' => 'prefix_parameter_id',
                'is_collection' => true,
            ],
        ],
    ],
];
