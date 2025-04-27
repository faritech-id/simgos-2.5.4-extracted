<?php
return [
    'controllers' => [
        'factories' => [
            'Dashboard\\V1\\Rpc\\Indikator\\Controller' => \Dashboard\V1\Rpc\Indikator\IndikatorControllerFactory::class,
            'Dashboard\\V1\\Rpc\\Pengunjung\\Controller' => \Dashboard\V1\Rpc\Pengunjung\PengunjungControllerFactory::class,
            'Dashboard\\V1\\Rpc\\Kunjungan\\Controller' => \Dashboard\V1\Rpc\Kunjungan\KunjunganControllerFactory::class,
            'Dashboard\\V1\\Rpc\\RawatInap\\Controller' => \Dashboard\V1\Rpc\RawatInap\RawatInapControllerFactory::class,
            'Dashboard\\V1\\Rpc\\Radiologi\\Controller' => \Dashboard\V1\Rpc\Radiologi\RadiologiControllerFactory::class,
            'Dashboard\\V1\\Rpc\\Laboratorium\\Controller' => \Dashboard\V1\Rpc\Laboratorium\LaboratoriumControllerFactory::class,
            'Dashboard\\V1\\Rpc\\KlaimInacbg\\Controller' => \Dashboard\V1\Rpc\KlaimInacbg\KlaimInacbgControllerFactory::class,
            'Dashboard\\V1\\Rpc\\KlaimIks\\Controller' => \Dashboard\V1\Rpc\KlaimIks\KlaimIksControllerFactory::class,
            'Dashboard\\V1\\Rpc\\Penerimaan\\Controller' => \Dashboard\V1\Rpc\Penerimaan\PenerimaanControllerFactory::class,
            'Dashboard\\V1\\Rpc\\Pendapatan\\Controller' => \Dashboard\V1\Rpc\Pendapatan\PendapatanControllerFactory::class,
            'Dashboard\\V1\\Rpc\\KasusDiagnosa\\Controller' => \Dashboard\V1\Rpc\KasusDiagnosa\KasusDiagnosaControllerFactory::class,
            'Dashboard\\V1\\Rpc\\KasusDiagnosaInacbg\\Controller' => \Dashboard\V1\Rpc\KasusDiagnosaInacbg\KasusDiagnosaInacbgControllerFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'dashboard.rpc.indikator' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/indikator[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Indikator\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.pengunjung' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/layanan/pengunjung[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Pengunjung\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.kunjungan' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/layanan/kunjungan[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Kunjungan\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.rawat-inap' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/layanan/rawatinap[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\RawatInap\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.radiologi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/layanan/penunjang/radiologi[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Radiologi\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.laboratorium' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/layanan/penunjang/laboratorium[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Laboratorium\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.klaim-inacbg' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/klaim/inacbg[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\KlaimInacbg\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.klaim-iks' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/klaim/iks[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\KlaimIks\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.penerimaan' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/keuangan/penerimaan[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Penerimaan\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.pendapatan' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/keuangan/pendapatan[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\Pendapatan\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.kasus-diagnosa' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/kasus/diagnosa[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\KasusDiagnosa\\Controller',
                    ],
                ],
            ],
            'dashboard.rpc.kasus-diagnosa-inacbg' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/dashboard/kasus/diagnosa/inacbg[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Dashboard\\V1\\Rpc\\KasusDiagnosaInacbg\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            0 => 'dashboard.rpc.indikator',
            1 => 'dashboard.rpc.pengunjung',
            2 => 'dashboard.rpc.kunjungan',
            3 => 'dashboard.rpc.rawat-inap',
            4 => 'dashboard.rpc.radiologi',
            5 => 'dashboard.rpc.laboratorium',
            6 => 'dashboard.rpc.klaim-inacbg',
            7 => 'dashboard.rpc.klaim-iks',
            8 => 'dashboard.rpc.penerimaan',
            9 => 'dashboard.rpc.pendapatan',
            10 => 'dashboard.rpc.kasus-diagnosa',
            11 => 'dashboard.rpc.kasus-diagnosa-inacbg',
        ],
    ],
    'api-tools-rpc' => [
        'Dashboard\\V1\\Rpc\\Indikator\\Controller' => [
            'service_name' => 'Indikator',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.indikator',
        ],
        'Dashboard\\V1\\Rpc\\Pengunjung\\Controller' => [
            'service_name' => 'Pengunjung',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.pengunjung',
        ],
        'Dashboard\\V1\\Rpc\\Kunjungan\\Controller' => [
            'service_name' => 'Kunjungan',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.kunjungan',
        ],
        'Dashboard\\V1\\Rpc\\RawatInap\\Controller' => [
            'service_name' => 'RawatInap',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.rawat-inap',
        ],
        'Dashboard\\V1\\Rpc\\Radiologi\\Controller' => [
            'service_name' => 'Radiologi',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.radiologi',
        ],
        'Dashboard\\V1\\Rpc\\Laboratorium\\Controller' => [
            'service_name' => 'Laboratorium',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.laboratorium',
        ],
        'Dashboard\\V1\\Rpc\\KlaimInacbg\\Controller' => [
            'service_name' => 'KlaimInacbg',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.klaim-inacbg',
        ],
        'Dashboard\\V1\\Rpc\\KlaimIks\\Controller' => [
            'service_name' => 'KlaimIks',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.klaim-iks',
        ],
        'Dashboard\\V1\\Rpc\\Penerimaan\\Controller' => [
            'service_name' => 'Penerimaan',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.penerimaan',
        ],
        'Dashboard\\V1\\Rpc\\Pendapatan\\Controller' => [
            'service_name' => 'Pendapatan',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.pendapatan',
        ],
        'Dashboard\\V1\\Rpc\\KasusDiagnosa\\Controller' => [
            'service_name' => 'KasusDiagnosa',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.kasus-diagnosa',
        ],
        'Dashboard\\V1\\Rpc\\KasusDiagnosaInacbg\\Controller' => [
            'service_name' => 'KasusDiagnosaInacbg',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'dashboard.rpc.kasus-diagnosa-inacbg',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Dashboard\\V1\\Rpc\\Indikator\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\Pengunjung\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\Kunjungan\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\RawatInap\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\Radiologi\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\Laboratorium\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\KlaimInacbg\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\KlaimIks\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\Penerimaan\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\Pendapatan\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\KasusDiagnosa\\Controller' => 'Json',
            'Dashboard\\V1\\Rpc\\KasusDiagnosaInacbg\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Dashboard\\V1\\Rpc\\Indikator\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\Pengunjung\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\Kunjungan\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\RawatInap\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\Radiologi\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\Laboratorium\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\KlaimInacbg\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\KlaimIks\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\Penerimaan\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\Pendapatan\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\KasusDiagnosa\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Dashboard\\V1\\Rpc\\KasusDiagnosaInacbg\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
        ],
        'content_type_whitelist' => [
            'Dashboard\\V1\\Rpc\\Indikator\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\Pengunjung\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\Kunjungan\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\RawatInap\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\Radiologi\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\Laboratorium\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\KlaimInacbg\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\KlaimIks\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\Penerimaan\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\Pendapatan\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\KasusDiagnosa\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
            'Dashboard\\V1\\Rpc\\KasusDiagnosaInacbg\\Controller' => [
                0 => 'application/vnd.dashboard.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
];
