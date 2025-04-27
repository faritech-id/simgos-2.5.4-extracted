<?php
return [
    'controllers' => [
        'factories' => [
            'DocumentStorage\\V1\\Rpc\\Document\\Controller' => \DocumentStorage\V1\Rpc\Document\DocumentControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'document-storage.rpc.document' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/document-storage/document[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'DocumentStorage\\V1\\Rpc\\Document\\Controller',
                    ],
                ],
            ],
            'document-storage.rest.document-directory' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/document-storage/document-directory[/:document_directory_id]',
                    'defaults' => [
                        'controller' => 'DocumentStorage\\V1\\Rest\\DocumentDirectory\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'document-storage.rpc.document',
            1 => 'document-storage.rest.document-directory',
        ],
    ],
    'api-tools-rpc' => [
        'DocumentStorage\\V1\\Rpc\\Document\\Controller' => [
            'service_name' => 'Document',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
            ],
            'route_name' => 'document-storage.rpc.document',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'DocumentStorage\\V1\\Rpc\\Document\\Controller' => 'Json',
            'DocumentStorage\\V1\\Rest\\DocumentDirectory\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'DocumentStorage\\V1\\Rpc\\Document\\Controller' => [
                0 => 'application/vnd.document-storage.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'DocumentStorage\\V1\\Rest\\DocumentDirectory\\Controller' => [
                0 => 'application/vnd.document-storage.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'DocumentStorage\\V1\\Rpc\\Document\\Controller' => [
                0 => 'application/vnd.document-storage.v1+json',
                1 => 'application/json',
            ],
            'DocumentStorage\\V1\\Rest\\DocumentDirectory\\Controller' => [
                0 => 'application/vnd.document-storage.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'service_manager' => [
        'factories' => [
            \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryResource::class => \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryResourceFactory::class,
        ],
    ],
    'api-tools-rest' => [
        'DocumentStorage\\V1\\Rest\\DocumentDirectory\\Controller' => [
            'listener' => \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryResource::class,
            'route_name' => 'document-storage.rest.document-directory',
            'route_identifier_name' => 'document_directory_id',
            'collection_name' => 'document_directory',
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
            'entity_class' => \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryEntity::class,
            'collection_class' => \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryCollection::class,
            'service_name' => 'DocumentDirectory',
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'document-storage.rest.document-directory',
                'route_identifier_name' => 'document_directory_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \DocumentStorage\V1\Rest\DocumentDirectory\DocumentDirectoryCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'document-storage.rest.document-directory',
                'route_identifier_name' => 'document_directory_id',
                'is_collection' => true,
            ],
        ],
    ],
];
