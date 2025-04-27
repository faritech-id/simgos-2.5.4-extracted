<?php
return [
    'controllers' => [
        'factories' => [
            'Plugins\\V1\\Rpc\\Bpjs\\Controller' => \Plugins\V1\Rpc\Bpjs\BpjsControllerFactory::class,
            'Plugins\\V1\\Rpc\\Inasis\\Controller' => \Plugins\V1\Rpc\Inasis\InasisControllerFactory::class,
            'Plugins\\V1\\Rpc\\Inacbg\\Controller' => \Plugins\V1\Rpc\Inacbg\InacbgControllerFactory::class,
            'Plugins\\V2\\Rpc\\Bpjs\\Controller' => \Plugins\V2\Rpc\Bpjs\BpjsControllerFactory::class,
            'Plugins\\V2\\Rpc\\Inacbg\\Controller' => \Plugins\V2\Rpc\Inacbg\InacbgControllerFactory::class,
            'Plugins\\V2\\Rpc\\Kemkes\\Controller' => \Plugins\V2\Rpc\Kemkes\KemkesControllerFactory::class,
            'Plugins\\V2\\Rpc\\Dukcapil\\Controller' => \Plugins\V2\Rpc\Dukcapil\DukcapilControllerFactory::class,
            'Plugins\\V2\\Rpc\\Pusdatin\\Controller' => \Plugins\V2\Rpc\Pusdatin\PusdatinControllerFactory::class,
            'Plugins\\V2\\Rpc\\TTS\\Controller' => \Plugins\V2\Rpc\TTS\TTSControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'plugins.rest.request-report' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/request-report[/:request_report_id]',
                    'defaults' => [
                        'controller' => 'Plugins\\V1\\Rest\\RequestReport\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.bpjs' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/bpjs[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V1\\Rpc\\Bpjs\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.inasis' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/inasis[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V1\\Rpc\\Inasis\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.inacbg' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/inacbg[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V1\\Rpc\\Inacbg\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.kemkes' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/kemkes[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V2\\Rpc\\Kemkes\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.dukcapil' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/dukcapil[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V2\\Rpc\\Dukcapil\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.pusdatin' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/pusdatin[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V2\\Rpc\\Pusdatin\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.tts' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/plugins/tts[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Plugins\\V2\\Rpc\\TTS\\Controller',
                    ],
                ],
            ],
            'plugins.rpc.ping' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/ping',
                    'defaults' => [
                        'controller' => 'Plugins\\V2\\Rpc\\Ping\\Controller',
                        'action' => 'ping',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'plugins.rest.request-report',
            1 => 'plugins.rpc.bpjs',
            2 => 'plugins.rpc.inasis',
            3 => 'plugins.rpc.inacbg',
            4 => 'plugins.rpc.kemkes',
            5 => 'plugins.rpc.dukcapil',
            6 => 'plugins.rpc.pusdatin',
            7 => 'plugins.rpc.tts',
            8 => 'plugins.rpc.ping',
        ],
        'default_version' => 2,
        'module_default_version' => [
            'plugins' => 2,
        ],
    ],
    'service_manager' => [
        'factories' => [
            \Plugins\V1\Rest\RequestReport\RequestReportResource::class => \Plugins\V1\Rest\RequestReport\RequestReportResourceFactory::class,
            \Plugins\V2\Rest\RequestReport\RequestReportResource::class => \Plugins\V2\Rest\RequestReport\RequestReportResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'Plugins\\V1\\Rest\\RequestReport\\Controller' => [
            'listener' => \Plugins\V1\Rest\RequestReport\RequestReportResource::class,
            'route_name' => 'plugins.rest.request-report',
            'route_identifier_name' => 'request_report_id',
            'collection_name' => 'request_report',
            'entity_http_methods' => [],
            'collection_http_methods' => [
                0 => 'POST',
            ],
            'collection_query_whitelist' => [],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Plugins\V1\Rest\RequestReport\RequestReportEntity::class,
            'collection_class' => \Plugins\V1\Rest\RequestReport\RequestReportCollection::class,
            'service_name' => 'RequestReport',
        ],
        'Plugins\\V2\\Rest\\RequestReport\\Controller' => [
            'listener' => \Plugins\V2\Rest\RequestReport\RequestReportResource::class,
            'route_name' => 'plugins.rest.request-report',
            'route_identifier_name' => 'request_report_id',
            'collection_name' => 'request_report',
            'entity_http_methods' => [
                0 => 'GET',
                1 => 'PATCH',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'collection_http_methods' => [
                0 => 'POST',
                1 => 'GET',
            ],
            'collection_query_whitelist' => [
                0 => 'DOCUMENT_DIRECTORY_ID',
                1 => 'REF_ID',
                2 => 'start',
                3 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Plugins\V2\Rest\RequestReport\RequestReportEntity::class,
            'collection_class' => \Plugins\V2\Rest\RequestReport\RequestReportCollection::class,
            'service_name' => 'RequestReport',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Plugins\\V1\\Rest\\RequestReport\\Controller' => 'Json',
            'Plugins\\V1\\Rpc\\Bpjs\\Controller' => 'Json',
            'Plugins\\V1\\Rpc\\Inasis\\Controller' => 'Json',
            'Plugins\\V1\\Rpc\\Inacbg\\Controller' => 'Json',
            'Plugins\\V2\\Rest\\RequestReport\\Controller' => 'Json',
            'Plugins\\V2\\Rpc\\Bpjs\\Controller' => 'Json',
            'Plugins\\V2\\Rpc\\Inacbg\\Controller' => 'Json',
            'Plugins\\V2\\Rpc\\Kemkes\\Controller' => 'Json',
            'Plugins\\V2\\Rpc\\Dukcapil\\Controller' => 'Json',
            'Plugins\\V2\\Rpc\\Pusdatin\\Controller' => 'Json',
            'Plugins\\V2\\Rpc\\TTS\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Plugins\\V1\\Rest\\RequestReport\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Plugins\\V1\\Rpc\\Bpjs\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V1\\Rpc\\Inasis\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V1\\Rpc\\Inacbg\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V2\\Rest\\RequestReport\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\Bpjs\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V2\\Rpc\\Inacbg\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V2\\Rpc\\Kemkes\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V2\\Rpc\\Dukcapil\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V2\\Rpc\\Pusdatin\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Plugins\\V2\\Rpc\\TTS\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'Plugins\\V1\\Rest\\RequestReport\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
            ],
            'Plugins\\V1\\Rpc\\Bpjs\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
            ],
            'Plugins\\V1\\Rpc\\Inasis\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
            ],
            'Plugins\\V1\\Rpc\\Inacbg\\Controller' => [
                0 => 'application/vnd.plugins.v1+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rest\\RequestReport\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\Bpjs\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\Inacbg\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\Kemkes\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\Dukcapil\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\Pusdatin\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
            'Plugins\\V2\\Rpc\\TTS\\Controller' => [
                0 => 'application/vnd.plugins.v2+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \Plugins\V1\Rest\RequestReport\RequestReportEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'plugins.rest.request-report',
                'route_identifier_name' => 'request_report_id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \Plugins\V1\Rest\RequestReport\RequestReportCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'plugins.rest.request-report',
                'route_identifier_name' => 'request_report_id',
                'is_collection' => true,
            ],
            \Plugins\V2\Rest\RequestReport\RequestReportEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'plugins.rest.request-report',
                'route_identifier_name' => 'request_report_id',
                'hydrator' => 'Laminas\\Stdlib\\Hydrator\\ArraySerializableHydrator',
            ],
            \Plugins\V2\Rest\RequestReport\RequestReportCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'plugins.rest.request-report',
                'route_identifier_name' => 'request_report_id',
                'is_collection' => '1',
            ],
        ],
    ],
    'api-tools-content-validation' => [
        'Plugins\\V1\\Rest\\RequestReport\\Controller' => [
            'input_filter' => 'Plugins\\V1\\Rest\\RequestReport\\Validator',
        ],
        'Plugins\\V2\\Rest\\RequestReport\\Controller' => [
            'input_filter' => 'Plugins\\V2\\Rest\\RequestReport\\Validator',
        ],
    ],
    'input_filter_specs' => [
        'Plugins\\V1\\Rest\\RequestReport\\Validator' => [
            0 => [
                'name' => 'NAME',
                'required' => true,
                'filters' => [],
                'validators' => [],
                'allow_empty' => false,
                'continue_if_empty' => false,
            ],
            1 => [
                'name' => 'CONNECTION_NUMBER',
                'required' => true,
                'filters' => [],
                'validators' => [],
                'allow_empty' => false,
                'continue_if_empty' => false,
            ],
            2 => [
                'name' => 'TYPE',
                'required' => true,
                'filters' => [],
                'validators' => [],
                'allow_empty' => false,
                'continue_if_empty' => false,
            ],
            3 => [
                'name' => 'PARAMETER',
                'required' => true,
                'filters' => [],
                'validators' => [],
                'allow_empty' => false,
                'continue_if_empty' => true,
            ],
            4 => [
                'name' => 'REQUEST_FOR_PRINT',
                'required' => true,
                'filters' => [],
                'validators' => [],
                'allow_empty' => false,
                'continue_if_empty' => true,
            ],
        ],
        'Plugins\\V2\\Rest\\RequestReport\\Validator' => [],
    ],
    'api-tools-rpc' => [
        'Plugins\\V1\\Rpc\\Bpjs\\Controller' => [
            'service_name' => 'bpjs',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'route_name' => 'plugins.rpc.bpjs',
        ],
        'Plugins\\V1\\Rpc\\Inasis\\Controller' => [
            'service_name' => 'inasis',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'route_name' => 'plugins.rpc.inasis',
        ],
        'Plugins\\V1\\Rpc\\Inacbg\\Controller' => [
            'service_name' => 'inacbg',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'plugins.rpc.inacbg',
        ],
        'Plugins\\V2\\Rpc\\Bpjs\\Controller' => [
            'service_name' => 'bpjs',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'route_name' => 'plugins.rpc.bpjs',
        ],
        'Plugins\\V2\\Rpc\\Inacbg\\Controller' => [
            'service_name' => 'inacbg',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'plugins.rpc.inacbg',
        ],
        'Plugins\\V2\\Rpc\\Kemkes\\Controller' => [
            'service_name' => 'Kemkes',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'route_name' => 'plugins.rpc.kemkes',
        ],
        'Plugins\\V2\\Rpc\\Dukcapil\\Controller' => [
            'service_name' => 'Dukcapil',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'plugins.rpc.dukcapil',
        ],
        'Plugins\\V2\\Rpc\\Pusdatin\\Controller' => [
            'service_name' => 'Pusdatin',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'plugins.rpc.pusdatin',
        ],
        'Plugins\\V2\\Rpc\\TTS\\Controller' => [
            'service_name' => 'TTS',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'plugins.rpc.tts',
        ],
    ],
];
