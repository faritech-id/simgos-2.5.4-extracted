<?php
return [
    'controllers' => [
        'factories' => [
            'Kemkes\\SIRS\\V1\\Rpc\\RL12\\Controller' => \Kemkes\SIRS\V1\Rpc\RL12\RL12ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL13\\Controller' => \Kemkes\SIRS\V1\Rpc\RL13\RL13ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller' => \Kemkes\SIRS\V1\Rpc\RL31\RL31ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller' => \Kemkes\SIRS\V1\Rpc\RL32\RL32ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller' => \Kemkes\SIRS\V1\Rpc\RL33\RL33ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller' => \Kemkes\SIRS\V1\Rpc\RL34\RL34ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller' => \Kemkes\SIRS\V1\Rpc\RL35\RL35ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller' => \Kemkes\SIRS\V1\Rpc\RL36\RL36ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller' => \Kemkes\SIRS\V1\Rpc\RL37\RL37ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller' => \Kemkes\SIRS\V1\Rpc\RL38\RL38ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller' => \Kemkes\SIRS\V1\Rpc\RL39\RL39ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller' => \Kemkes\SIRS\V1\Rpc\RL310\RL310ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller' => \Kemkes\SIRS\V1\Rpc\RL311\RL311ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller' => \Kemkes\SIRS\V1\Rpc\RL312\RL312ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller' => \Kemkes\SIRS\V1\Rpc\RL313\RL313ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller' => \Kemkes\SIRS\V1\Rpc\RL313b\RL313bControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller' => \Kemkes\SIRS\V1\Rpc\RL314\RL314ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller' => \Kemkes\SIRS\V1\Rpc\RL315\RL315ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL4a\\Controller' => \Kemkes\SIRS\V1\Rpc\RL4a\RL4aControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller' => \Kemkes\SIRS\V1\Rpc\RL4aSebab\RL4aSebabControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller' => \Kemkes\SIRS\V1\Rpc\RL4b\RL4bControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller' => \Kemkes\SIRS\V1\Rpc\RL4bSebab\RL4bSebabControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller' => \Kemkes\SIRS\V1\Rpc\RL51\RL51ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller' => \Kemkes\SIRS\V1\Rpc\RL52\RL52ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller' => \Kemkes\SIRS\V1\Rpc\RL53\RL53ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller' => \Kemkes\SIRS\V1\Rpc\RL54\RL54ControllerFactory::class,
            'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller' => \Kemkes\SIRS\V1\Rpc\RL2\RL2ControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'kemkes-sirs.rpc.rl12' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/1-2[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL12\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl13' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/1-3[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL13\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl31' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-1[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl32' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-2[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl33' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-3[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl34' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-4[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl35' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-5[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl36' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-6[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl37' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-7[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl38' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-8[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl39' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-9[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl310' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-10[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl311' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-11[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl312' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-12[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl313' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-13[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl313b' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-13b[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl314' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-14[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl315' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/3-15[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl4a' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/4a[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL4a\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl4a-sebab' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/4a-sebab[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl4b' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/4b[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl4b-sebab' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/4b-sebab[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl51' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/5-1[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl52' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/5-2[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl53' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/5-3[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl54' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/5-4[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller',
                    ],
                ],
            ],
            'kemkes-sirs.rpc.rl2' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/sirs/rl/2[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            1 => 'kemkes-sirs.rpc.rl12',
            0 => 'kemkes-sirs.rpc.rl13',
            2 => 'kemkes-sirs.rpc.rl31',
            3 => 'kemkes-sirs.rpc.rl32',
            4 => 'kemkes-sirs.rpc.rl33',
            5 => 'kemkes-sirs.rpc.rl34',
            6 => 'kemkes-sirs.rpc.rl35',
            7 => 'kemkes-sirs.rpc.rl36',
            8 => 'kemkes-sirs.rpc.rl37',
            9 => 'kemkes-sirs.rpc.rl38',
            10 => 'kemkes-sirs.rpc.rl39',
            11 => 'kemkes-sirs.rpc.rl310',
            12 => 'kemkes-sirs.rpc.rl311',
            13 => 'kemkes-sirs.rpc.rl312',
            14 => 'kemkes-sirs.rpc.rl313',
            15 => 'kemkes-sirs.rpc.rl313b',
            16 => 'kemkes-sirs.rpc.rl314',
            17 => 'kemkes-sirs.rpc.rl315',
            18 => 'kemkes-sirs.rpc.rl4a',
            19 => 'kemkes-sirs.rpc.rl4a-sebab',
            20 => 'kemkes-sirs.rpc.rl4b',
            21 => 'kemkes-sirs.rpc.rl4b-sebab',
            22 => 'kemkes-sirs.rpc.rl51',
            23 => 'kemkes-sirs.rpc.rl52',
            24 => 'kemkes-sirs.rpc.rl53',
            25 => 'kemkes-sirs.rpc.rl54',
            26 => 'kemkes-sirs.rpc.rl2',
        ],
    ],
    'api-tools-rpc' => [
        'Kemkes\\SIRS\\V1\\Rpc\\RL12\\Controller' => [
            'service_name' => 'RL12',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl12',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL13\\Controller' => [
            'service_name' => 'RL13',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl13',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller' => [
            'service_name' => 'RL31',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl31',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller' => [
            'service_name' => 'RL32',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl32',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller' => [
            'service_name' => 'RL33',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl33',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller' => [
            'service_name' => 'RL34',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl34',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller' => [
            'service_name' => 'RL35',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl35',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller' => [
            'service_name' => 'RL36',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl36',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller' => [
            'service_name' => 'RL37',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl37',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller' => [
            'service_name' => 'RL38',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl38',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller' => [
            'service_name' => 'RL39',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl39',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller' => [
            'service_name' => 'RL310',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl310',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller' => [
            'service_name' => 'RL311',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl311',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller' => [
            'service_name' => 'RL312',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl312',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller' => [
            'service_name' => 'RL313',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl313',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller' => [
            'service_name' => 'RL313b',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl313b',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller' => [
            'service_name' => 'RL314',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl314',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller' => [
            'service_name' => 'RL315',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl315',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL4a\\Controller' => [
            'service_name' => 'RL4a',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl4a',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller' => [
            'service_name' => 'RL4aSebab',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl4a-sebab',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller' => [
            'service_name' => 'RL4b',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl4b',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller' => [
            'service_name' => 'RL4bSebab',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl4b-sebab',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller' => [
            'service_name' => 'RL51',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl51',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller' => [
            'service_name' => 'RL52',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl52',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller' => [
            'service_name' => 'RL53',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl53',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller' => [
            'service_name' => 'RL54',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl54',
        ],
        'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller' => [
            'service_name' => 'RL2',
            'http_methods' => [
                0 => 'GET',
                1 => 'DELETE',
            ],
            'route_name' => 'kemkes-sirs.rpc.rl2',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Kemkes\\SIRS\\V1\\Rpc\\RL12\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL13\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL4a\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller' => 'Json',
            'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Kemkes\\SIRS\\V1\\Rpc\\RL12\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL13\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4a\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'Kemkes\\SIRS\\V1\\Rpc\\RL12\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL13\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4a\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller' => [
                0 => 'application/vnd.kemkes-sirs.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-mvc-auth' => [
        'authorization' => [
            'Kemkes\\SIRS\\V1\\Rpc\\RL33\\Controller' => [
                'actions' => [
                    'rL33' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL31\\Controller' => [
                'actions' => [
                    'rL31' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL32\\Controller' => [
                'actions' => [
                    'rL32' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL34\\Controller' => [
                'actions' => [
                    'rL34' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL35\\Controller' => [
                'actions' => [
                    'rL35' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL36\\Controller' => [
                'actions' => [
                    'rL36' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL37\\Controller' => [
                'actions' => [
                    'rL37' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL38\\Controller' => [
                'actions' => [
                    'rL38' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL39\\Controller' => [
                'actions' => [
                    'rL39' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL310\\Controller' => [
                'actions' => [
                    'rL310' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL311\\Controller' => [
                'actions' => [
                    'rL311' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL312\\Controller' => [
                'actions' => [
                    'rL312' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL313\\Controller' => [
                'actions' => [
                    'rL313' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL313b\\Controller' => [
                'actions' => [
                    'rL313b' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL314\\Controller' => [
                'actions' => [
                    'rL314' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL315\\Controller' => [
                'actions' => [
                    'rL315' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4aSebab\\Controller' => [
                'actions' => [
                    'rL4aSebab' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4b\\Controller' => [
                'actions' => [
                    'rL4b' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL4bSebab\\Controller' => [
                'actions' => [
                    'rL4bSebab' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL51\\Controller' => [
                'actions' => [
                    'rL51' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL52\\Controller' => [
                'actions' => [
                    'rL52' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL54\\Controller' => [
                'actions' => [
                    'rL54' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL53\\Controller' => [
                'actions' => [
                    'rL53' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
            'Kemkes\\SIRS\\V1\\Rpc\\RL2\\Controller' => [
                'actions' => [
                    'rL2' => [
                        'GET' => true,
                        'POST' => false,
                        'PUT' => false,
                        'PATCH' => false,
                        'DELETE' => true,
                    ],
                ],
            ],
        ],
    ],
];
