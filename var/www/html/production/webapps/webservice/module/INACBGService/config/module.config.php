<?php
return [
    'controllers' => [
        'factories' => [
            'INACBGService\\V1\\Rpc\\Grouper\\Controller' => \INACBGService\V1\Rpc\Grouper\GrouperControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'inacbg-service.rpc.grouper' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/grouper[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rpc\\Grouper\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.map' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/map[/:id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\Map\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.inacbg' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/inacbg[/:id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\Inacbg\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.list-procedure' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/listprocedure[/:id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\ListProcedure\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.grouping' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/grouping[/:id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\Grouping\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.hasil-grouping' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/hasilgrouping[/:id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\HasilGrouping\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.tipe-inacbg' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/tipe[/:id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\TipeINACBG\\Controller',
                    ],
                ],
            ],
            'inacbg-service.rest.icdina-grouper' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/inacbgservice/icdina-grouper[/:icdina_grouper_id]',
                    'defaults' => [
                        'controller' => 'INACBGService\\V1\\Rest\\ICDINAGrouper\\Controller',
                    ],
                ],
            ],            
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'inacbg-service.rpc.grouper',
            3 => 'inacbg-service.rest.map',
            4 => 'inacbg-service.rest.inacbg',
            5 => 'inacbg-service.rest.list-procedure',
            6 => 'inacbg-service.rest.grouping',
            7 => 'inacbg-service.rest.hasil-grouping',
            8 => 'inacbg-service.rest.tipe-inacbg',
            9 => 'inacbg-service.rest.icdina-grouper',
            10 => 'inacbg-service.rest.icdina-grouper',            
        ],
    ],
    'api-tools-rpc' => [
        'INACBGService\\V1\\Rpc\\Grouper\\Controller' => [
            'service_name' => 'Grouper',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'inacbg-service.rpc.grouper',
        ],        
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'INACBGService\\V1\\Rpc\\Grouper\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\Map\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\Inacbg\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\ListProcedure\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\Grouping\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\HasilGrouping\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\TipeINACBG\\Controller' => 'Json',
            'INACBGService\\V1\\Rest\\ICDINAGrouper\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'INACBGService\\V1\\Rpc\\Grouper\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'INACBGService\\V1\\Rest\\Map\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\Inacbg\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\ListProcedure\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\Grouping\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\HasilGrouping\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\TipeINACBG\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\ICDINAGrouper\\Controller' => [
                0 => 'application/vnd.inacbg-service.V1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],            
        ],
        'content_type_whitelist' => [
            'INACBGService\\V1\\Rpc\\Grouper\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\Map\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\Inacbg\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\ListProcedure\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\Grouping\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\HasilGrouping\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\TipeINACBG\\Controller' => [
                0 => 'application/vnd.inacbg-service.v1+json',
                1 => 'application/json',
            ],
            'INACBGService\\V1\\Rest\\ICDINAGrouper\\Controller' => [
                0 => 'application/vnd.inacbg-service.V1+json',
                1 => 'application/json',
            ],            
        ],
    ],
    'service_manager' => [
        'factories' => [
            \INACBGService\V1\Rest\Map\MapResource::class => \INACBGService\V1\Rest\Map\MapResourceFactory::class,
            \INACBGService\V1\Rest\Inacbg\InacbgResource::class => \INACBGService\V1\Rest\Inacbg\InacbgResourceFactory::class,
            \INACBGService\V1\Rest\ListProcedure\ListProcedureResource::class => \INACBGService\V1\Rest\ListProcedure\ListProcedureResourceFactory::class,
            \INACBGService\V1\Rest\Grouping\GroupingResource::class => \INACBGService\V1\Rest\Grouping\GroupingResourceFactory::class,
            \INACBGService\V1\Rest\HasilGrouping\HasilGroupingResource::class => \INACBGService\V1\Rest\HasilGrouping\HasilGroupingResourceFactory::class,
            \INACBGService\V1\Rest\TipeINACBG\TipeINACBGResource::class => \INACBGService\V1\Rest\TipeINACBG\TipeINACBGResourceFactory::class,
            \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperResource::class => \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'INACBGService\\V1\\Rest\\Map\\Controller' => [
            'listener' => \INACBGService\V1\Rest\Map\MapResource::class,
            'route_name' => 'inacbg-service.rest.map',
            'route_identifier_name' => 'id',
            'collection_name' => 'map',
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
                1 => 'STATUS',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \INACBGService\V1\Rest\Map\MapEntity::class,
            'collection_class' => \INACBGService\V1\Rest\Map\MapCollection::class,
            'service_name' => 'map',
        ],
        'INACBGService\\V1\\Rest\\Inacbg\\Controller' => [
            'listener' => \INACBGService\V1\Rest\Inacbg\InacbgResource::class,
            'route_name' => 'inacbg-service.rest.inacbg',
            'route_identifier_name' => 'id',
            'collection_name' => 'inacbg',
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
                1 => 'VERSION',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \INACBGService\V1\Rest\Inacbg\InacbgEntity::class,
            'collection_class' => \INACBGService\V1\Rest\Inacbg\InacbgCollection::class,
            'service_name' => 'inacbg',
        ],
        'INACBGService\\V1\\Rest\\ListProcedure\\Controller' => [
            'listener' => \INACBGService\V1\Rest\ListProcedure\ListProcedureResource::class,
            'route_name' => 'inacbg-service.rest.list-procedure',
            'route_identifier_name' => 'id',
            'collection_name' => 'list_procedure',
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
            'entity_class' => \INACBGService\V1\Rest\ListProcedure\ListProcedureEntity::class,
            'collection_class' => \INACBGService\V1\Rest\ListProcedure\ListProcedureCollection::class,
            'service_name' => 'ListProcedure',
        ],
        'INACBGService\\V1\\Rest\\Grouping\\Controller' => [
            'listener' => \INACBGService\V1\Rest\Grouping\GroupingResource::class,
            'route_name' => 'inacbg-service.rest.grouping',
            'route_identifier_name' => 'id',
            'collection_name' => 'grouping',
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
                0 => 'NOPEN',
                1 => 'DATA',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \INACBGService\V1\Rest\Grouping\GroupingEntity::class,
            'collection_class' => \INACBGService\V1\Rest\Grouping\GroupingCollection::class,
            'service_name' => 'Grouping',
        ],
        'INACBGService\\V1\\Rest\\HasilGrouping\\Controller' => [
            'listener' => \INACBGService\V1\Rest\HasilGrouping\HasilGroupingResource::class,
            'route_name' => 'inacbg-service.rest.hasil-grouping',
            'route_identifier_name' => 'id',
            'collection_name' => 'hasil_grouping',
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
                0 => 'NOPEN',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \INACBGService\V1\Rest\HasilGrouping\HasilGroupingEntity::class,
            'collection_class' => \INACBGService\V1\Rest\HasilGrouping\HasilGroupingCollection::class,
            'service_name' => 'HasilGrouping',
        ],
        'INACBGService\\V1\\Rest\\TipeINACBG\\Controller' => [
            'listener' => \INACBGService\V1\Rest\TipeINACBG\TipeINACBGResource::class,
            'route_name' => 'inacbg-service.rest.tipe-inacbg',
            'route_identifier_name' => 'id',
            'collection_name' => 'tipe_inacbg',
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
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \INACBGService\V1\Rest\TipeINACBG\TipeINACBGEntity::class,
            'collection_class' => \INACBGService\V1\Rest\TipeINACBG\TipeINACBGCollection::class,
            'service_name' => 'TipeINACBG',
        ],
        'INACBGService\\V1\\Rest\\ICDINAGrouper\\Controller' => [
            'listener' => \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperResource::class,
            'route_name' => 'inacbg-service.rest.icdina-grouper',
            'route_identifier_name' => 'icdina_grouper_id',
            'collection_name' => 'icdina_grouper',
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
                0 => 'query',
                1 => 'icd_type',
                2 => 'load_from_inacbg',
                3 => 'tipe',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperEntity::class,
            'collection_class' => \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperCollection::class,
            'service_name' => 'ICDINAGrouper',
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \INACBGService\V1\Rest\Map\MapEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.map',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \INACBGService\V1\Rest\Map\MapCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.map',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \INACBGService\V1\Rest\Inacbg\InacbgEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.inacbg',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \INACBGService\V1\Rest\Inacbg\InacbgCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.inacbg',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \INACBGService\V1\Rest\ListProcedure\ListProcedureEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.list-procedure',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \INACBGService\V1\Rest\ListProcedure\ListProcedureCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.list-procedure',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \INACBGService\V1\Rest\Grouping\GroupingEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.grouping',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \INACBGService\V1\Rest\Grouping\GroupingCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.grouping',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \INACBGService\V1\Rest\HasilGrouping\HasilGroupingEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.hasil-grouping',
                'route_identifier_name' => 'id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \INACBGService\V1\Rest\HasilGrouping\HasilGroupingCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.hasil-grouping',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \INACBGService\V1\Rest\TipeINACBG\TipeINACBGEntity::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'inacbg-service.rest.tipe-inacbg',
                'route_identifier_name' => 'id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \INACBGService\V1\Rest\TipeINACBG\TipeINACBGCollection::class => [
                'entity_identifier_name' => 'ID',
                'route_name' => 'inacbg-service.rest.tipe-inacbg',
                'route_identifier_name' => 'id',
                'is_collection' => true,
            ],
            \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.icdina-grouper',
                'route_identifier_name' => 'icdina_grouper_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \INACBGService\V1\Rest\ICDINAGrouper\ICDINAGrouperCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'inacbg-service.rest.icdina-grouper',
                'route_identifier_name' => 'icdina_grouper_id',
                'is_collection' => true,
            ],
        ],
    ],
];
