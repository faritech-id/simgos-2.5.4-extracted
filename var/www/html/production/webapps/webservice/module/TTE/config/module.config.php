<?php
return [
    'controllers' => [
        'factories' => [
            'TTE\\V1\\Rpc\\Sign\\Controller' => \TTE\V1\Rpc\Sign\SignControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'tte.rpc.sign' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/tte/sign[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9-]+',
                    ],
                    'defaults' => [
                        'controller' => 'TTE\\V1\\Rpc\\Sign\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'tte.rpc.sign',
        ],
    ],
    'api-tools-rpc' => [
        'TTE\\V1\\Rpc\\Sign\\Controller' => [
            'service_name' => 'Sign',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'route_name' => 'tte.rpc.sign',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'TTE\\V1\\Rpc\\Sign\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'TTE\\V1\\Rpc\\Sign\\Controller' => [
                0 => 'application/vnd.tte.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'TTE\\V1\\Rpc\\Sign\\Controller' => [
                0 => 'application/vnd.tte.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
];
