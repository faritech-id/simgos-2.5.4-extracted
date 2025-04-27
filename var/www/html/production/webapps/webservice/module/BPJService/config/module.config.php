<?php
return [
    'controllers' => [
        'factories' => [
            'BPJService\\V1\\Rpc\\Peserta\\Controller' => \BPJService\V1\Rpc\Peserta\PesertaControllerFactory::class,
            'BPJService\\V1\\Rpc\\Kunjungan\\Controller' => \BPJService\V1\Rpc\Kunjungan\KunjunganControllerFactory::class,
            'BPJService\\V1\\Rpc\\Referensi\\Controller' => \BPJService\V1\Rpc\Referensi\ReferensiControllerFactory::class,
            'BPJService\\V1\\Rpc\\Rujukan\\Controller' => \BPJService\V1\Rpc\Rujukan\RujukanControllerFactory::class,
            'BPJService\\V1\\Rpc\\Monitoring\\Controller' => \BPJService\V1\Rpc\Monitoring\MonitoringControllerFactory::class,
            'BPJService\\V1\\Rpc\\Aplicares\\Controller' => \BPJService\V1\Rpc\Aplicares\AplicaresControllerFactory::class,
            'BPJService\\V1\\Rpc\\RencanaKontrol\\Controller' => \BPJService\V1\Rpc\RencanaKontrol\RencanaKontrolControllerFactory::class,
            'BPJService\\V1\\Rpc\\PRB\\Controller' => \BPJService\V1\Rpc\PRB\PRBControllerFactory::class,
            'BPJService\\V1\\Rpc\\LPK\\Controller' => \BPJService\V1\Rpc\LPK\LPKControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'bpj-service.rpc.peserta' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/peserta[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\Peserta\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.kunjungan' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/kunjungan[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\Kunjungan\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.referensi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/referensi[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\Referensi\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.rujukan' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/rujukan[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\Rujukan\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.monitoring' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/monitoring[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\Monitoring\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.aplicares' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/aplicares[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\Aplicares\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.rencana-kontrol' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/rencana-kontrol[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\RencanaKontrol\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.prb' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/prb[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\PRB\\Controller',
                    ],
                ],
            ],
            'bpj-service.rpc.lpk' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/bpjservice/lpk[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'BPJService\\V1\\Rpc\\LPK\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'bpj-service.rpc.peserta',
            1 => 'bpj-service.rpc.kunjungan',
            2 => 'bpj-service.rpc.referensi',
            3 => 'bpj-service.rpc.rujukan',
            4 => 'bpj-service.rpc.monitoring',
            5 => 'bpj-service.rpc.aplicares',
            6 => 'bpj-service.rpc.rencana-kontrol',
            7 => 'bpj-service.rpc.prb',
            8 => 'bpj-service.rpc.lpk',
        ],
        'default_version' => 1,
    ],
    'api-tools-rpc' => [
        'BPJService\\V1\\Rpc\\Peserta\\Controller' => [
            'service_name' => 'Peserta',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'bpj-service.rpc.peserta',
        ],
        'BPJService\\V1\\Rpc\\Kunjungan\\Controller' => [
            'service_name' => 'Kunjungan',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'route_name' => 'bpj-service.rpc.kunjungan',
        ],
        'BPJService\\V1\\Rpc\\Referensi\\Controller' => [
            'service_name' => 'Referensi',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'bpj-service.rpc.referensi',
        ],
        'BPJService\\V1\\Rpc\\Rujukan\\Controller' => [
            'service_name' => 'Rujukan',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'route_name' => 'bpj-service.rpc.rujukan',
        ],
        'BPJService\\V1\\Rpc\\Monitoring\\Controller' => [
            'service_name' => 'Monitoring',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'bpj-service.rpc.monitoring',
        ],
        'BPJService\\V1\\Rpc\\Aplicares\\Controller' => [
            'service_name' => 'Aplicares',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
            ],
            'route_name' => 'bpj-service.rpc.aplicares',
        ],
        'BPJService\\V1\\Rpc\\RencanaKontrol\\Controller' => [
            'service_name' => 'RencanaKontrol',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'route_name' => 'bpj-service.rpc.rencana-kontrol',
        ],
        'BPJService\\V1\\Rpc\\PRB\\Controller' => [
            'service_name' => 'PRB',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'route_name' => 'bpj-service.rpc.prb',
        ],
        'BPJService\\V1\\Rpc\\LPK\\Controller' => [
            'service_name' => 'LPK',
            'http_methods' => [
                0 => 'GET',
                1 => 'POST',
                2 => 'PUT',
                3 => 'DELETE',
            ],
            'route_name' => 'bpj-service.rpc.lpk',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'BPJService\\V1\\Rpc\\Peserta\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\Kunjungan\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\Referensi\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\Rujukan\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\Monitoring\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\Aplicares\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\RencanaKontrol\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\PRB\\Controller' => 'Json',
            'BPJService\\V1\\Rpc\\LPK\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'BPJService\\V1\\Rpc\\Peserta\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\Kunjungan\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\Referensi\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\Rujukan\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\Monitoring\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\Aplicares\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\RencanaKontrol\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\PRB\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'BPJService\\V1\\Rpc\\LPK\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'BPJService\\V1\\Rpc\\Peserta\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\Kunjungan\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\Referensi\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\Rujukan\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\Monitoring\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\Aplicares\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\RencanaKontrol\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\PRB\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
            'BPJService\\V1\\Rpc\\LPK\\Controller' => [
                0 => 'application/vnd.bpj-service.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'service_manager' => [
        'factories' => [],
    ],
    'api-tools-rest' => [],
    'api-tools-hal' => [
        'metadata_map' => [],
    ],
];
