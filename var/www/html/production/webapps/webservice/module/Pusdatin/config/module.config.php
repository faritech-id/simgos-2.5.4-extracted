<?php
return [
    'controllers' => [
        'factories' => [
            'Pusdatin\\V1\\Rpc\\Adminduk\\Controller' => \Pusdatin\V1\Rpc\Adminduk\AdmindukControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'pusdatin.rpc.adminduk' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/pusdatin/adminduk[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Pusdatin\\V1\\Rpc\\Adminduk\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'pusdatin.rpc.adminduk',
        ],
        'default_version' => 1,
    ],
    'api-tools-rpc' => [
        'Pusdatin\\V1\\Rpc\\Adminduk\\Controller' => [
            'service_name' => 'Adminduk',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'pusdatin.rpc.adminduk',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Pusdatin\\V1\\Rpc\\Adminduk\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Pusdatin\\V1\\Rpc\\Adminduk\\Controller' => [
                0 => 'application/vnd.pusdatin.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'Pusdatin\\V1\\Rpc\\Adminduk\\Controller' => [
                0 => 'application/vnd.pusdatin.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
];
