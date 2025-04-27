<?php
return [
    'controllers' => [
        'factories' => [
            'BPJS\\ICare\\V1\\Rpc\\Validate\\Controller' => \BPJS\ICare\V1\Rpc\Validate\ValidateControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'bpjs-icare.rpc.validate' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjs/icare/validate[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJS\\ICare\\V1\\Rpc\\Validate\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'bpjs-icare.rpc.validate',
        ],
    ],
    'api-tools-rpc' => [
        'BPJS\\ICare\\V1\\Rpc\\Validate\\Controller' => [
            'service_name' => 'Validate',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'route_name' => 'bpjs-icare.rpc.validate',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'BPJS\\ICare\\V1\\Rpc\\Validate\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'BPJS\\ICare\\V1\\Rpc\\Validate\\Controller' => [
                0 => 'application/vnd.bpjs-icare.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'BPJS\\ICare\\V1\\Rpc\\Validate\\Controller' => [
                0 => 'application/vnd.bpjs-icare.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
];
