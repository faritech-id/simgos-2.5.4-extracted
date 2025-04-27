<?php
return [
    'service_manager' => [
        'factories' => [
            \Kemkes\RSOnline\V1\Rest\Pasien\PasienResource::class => \Kemkes\RSOnline\V1\Rest\Pasien\PasienResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienResource::class => \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMResource::class => \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDResource::class => \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurResource::class => \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukResource::class => \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidResource::class => \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidResource::class => \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarResource::class => \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarResourceFactory::class,
            \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineResource::class => \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineResourceFactory::class,
        ],
    ],
    'router' => [
        'routes' => [
            'kemkes-rsonline.rpc.referensi' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/referensi[/:action][/:id]',
                    'constraints' => [
                        'action' => '[a-zA-Z][a-zA-Z0-9_-]*',
                        'id' => '[a-zA-Z0-9]+',
                    ],
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rpc\\Referensi\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.pasien' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/pasien[/:pasien_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\Pasien\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.diagnosa-pasien' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/diagnosa-pasien[/:diagnosa_pasien_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\DiagnosaPasien\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.data-kebutuhan-sdm' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/data-kebutuhan-sdm[/:data_kebutuhan_sdm_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanSDM\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.data-kebutuhan-apd' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/data-kebutuhan-apd[/:data_kebutuhan_apd_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanAPD\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.data-tempat-tidur' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/data-tempat-tidur[/:data_tempat_tidur_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\DataTempatTidur\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.rekap-pasien-masuk' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/rekap-pasien/masuk[/:rekap_pasien_masuk_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienMasuk\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.rekap-pasien-komorbid' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/rekap-pasien/komorbid[/:rekap_pasien_komorbid_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKomorbid\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.rekap-pasien-non-komorbid' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/rekap-pasien/non-komorbid[/:rekap_pasien_non_komorbid_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienNonKomorbid\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.rekap-pasien-keluar' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/rekap-pasien/keluar[/:rekap_pasien_keluar_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKeluar\\Controller',
                    ],
                ],
            ],
            'kemkes-rsonline.rest.kamar-simrs-rs-online' => [
                'type' => 'Segment',
                'options' => [
                    'route' => '/kemkes/rsonline/kamar-simrs-rs-online[/:kamar_simrs_rs_online_id]',
                    'defaults' => [
                        'controller' => 'Kemkes\\RSOnline\\V1\\Rest\\KamarSimrsRsOnline\\Controller',
                    ],
                ],
            ],
        ],
    ],
    'api-tools-versioning' => [
        'uri' => [
            1 => 'kemkes-rsonline.rpc.dashboard',
            2 => 'kemkes-rsonline.rpc.referensi',
            3 => 'kemkes-rsonline.rest.pasien',
            4 => 'kemkes-rsonline.rest.diagnosa-pasien',
            5 => 'kemkes-rsonline.rest.data-kebutuhan-sdm',
            6 => 'kemkes-rsonline.rest.data-kebutuhan-apd',
            7 => 'kemkes-rsonline.rest.data-tempat-tidur',
            8 => 'kemkes-rsonline.rest.rekap-pasien-masuk',
            9 => 'kemkes-rsonline.rest.rekap-pasien-komorbid',
            10 => 'kemkes-rsonline.rest.rekap-pasien-non-komorbid',
            11 => 'kemkes-rsonline.rest.rekap-pasien-keluar',
            12 => 'kemkes-rsonline.rest.kamar-simrs-rs-online',
        ],
    ],
    'api-tools-rest' => [
        'Kemkes\\RSOnline\\V1\\Rest\\Pasien\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\Pasien\PasienResource::class,
            'route_name' => 'kemkes-rsonline.rest.pasien',
            'route_identifier_name' => 'pasien_id',
            'collection_name' => 'pasien',
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
                0 => 'nomr',
                1 => 'loadFromWs',
                2 => 'kirim',
                3 => 'start',
                4 => 'limit',
                5 => 'query',
                6 => 'hapus',
                7 => 'statistik',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\Pasien\PasienEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\Pasien\PasienCollection::class,
            'service_name' => 'Pasien',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\DiagnosaPasien\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienResource::class,
            'route_name' => 'kemkes-rsonline.rest.diagnosa-pasien',
            'route_identifier_name' => 'diagnosa_pasien_id',
            'collection_name' => 'diagnosa_pasien',
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
                0 => 'nomr',
                1 => 'loadFromWs',
                2 => 'kirim',
                3 => 'hapus',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienCollection::class,
            'service_name' => 'DiagnosaPasien',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanSDM\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMResource::class,
            'route_name' => 'kemkes-rsonline.rest.data-kebutuhan-sdm',
            'route_identifier_name' => 'data_kebutuhan_sdm_id',
            'collection_name' => 'data_kebutuhan_sdm',
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
                0 => 'loadFromWs',
                1 => 'kirim',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMCollection::class,
            'service_name' => 'DataKebutuhanSDM',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanAPD\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDResource::class,
            'route_name' => 'kemkes-rsonline.rest.data-kebutuhan-apd',
            'route_identifier_name' => 'data_kebutuhan_apd_id',
            'collection_name' => 'data_kebutuhan_apd',
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
                0 => 'loadFromWs',
                1 => 'kirim',
                2 => 'query',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDCollection::class,
            'service_name' => 'DataKebutuhanAPD',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\DataTempatTidur\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurResource::class,
            'route_name' => 'kemkes-rsonline.rest.data-tempat-tidur',
            'route_identifier_name' => 'data_tempat_tidur_id',
            'collection_name' => 'data_tempat_tidur',
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
                0 => 'loadFromWs',
                1 => 'kirim',
                2 => 'covid',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurCollection::class,
            'service_name' => 'DataTempatTidur',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienMasuk\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukResource::class,
            'route_name' => 'kemkes-rsonline.rest.rekap-pasien-masuk',
            'route_identifier_name' => 'rekap_pasien_masuk_id',
            'collection_name' => 'rekap_pasien_masuk',
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
                0 => 'loadFromWs',
                1 => 'kirim',
                2 => 'start',
                3 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukCollection::class,
            'service_name' => 'RekapPasienMasuk',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKomorbid\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidResource::class,
            'route_name' => 'kemkes-rsonline.rest.rekap-pasien-komorbid',
            'route_identifier_name' => 'rekap_pasien_komorbid_id',
            'collection_name' => 'rekap_pasien_komorbid',
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
                0 => 'loadFromWs',
                1 => 'kirim',
                2 => 'start',
                3 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidCollection::class,
            'service_name' => 'RekapPasienKomorbid',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienNonKomorbid\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidResource::class,
            'route_name' => 'kemkes-rsonline.rest.rekap-pasien-non-komorbid',
            'route_identifier_name' => 'rekap_pasien_non_komorbid_id',
            'collection_name' => 'rekap_pasien_non_komorbid',
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
                0 => 'loadFromWs',
                1 => 'kirim',
                2 => 'start',
                3 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidCollection::class,
            'service_name' => 'RekapPasienNonKomorbid',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKeluar\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarResource::class,
            'route_name' => 'kemkes-rsonline.rest.rekap-pasien-keluar',
            'route_identifier_name' => 'rekap_pasien_keluar_id',
            'collection_name' => 'rekap_pasien_keluar',
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
                0 => 'loadFromWs',
                1 => 'kirim',
                2 => 'start',
                3 => 'limit',
            ],
            'page_size' => 25,
            'page_size_param' => null,
            'entity_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarCollection::class,
            'service_name' => 'RekapPasienKeluar',
        ],
        'Kemkes\\RSOnline\\V1\\Rest\\KamarSimrsRsOnline\\Controller' => [
            'listener' => \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineResource::class,
            'route_name' => 'kemkes-rsonline.rest.kamar-simrs-rs-online',
            'route_identifier_name' => 'kamar_simrs_rs_online_id',
            'collection_name' => 'kamar_simrs_rs_online',
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
            'entity_class' => \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineEntity::class,
            'collection_class' => \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineCollection::class,
            'service_name' => 'KamarSimrsRsOnline',
        ],
    ],
    'api-tools-content-negotiation' => [
        'controllers' => [
            'Kemkes\\RSOnline\\V1\\Rpc\\Referensi\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\Pasien\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\DiagnosaPasien\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanSDM\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanAPD\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\DataTempatTidur\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienMasuk\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKomorbid\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienNonKomorbid\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKeluar\\Controller' => 'Json',
            'Kemkes\\RSOnline\\V1\\Rest\\KamarSimrsRsOnline\\Controller' => 'Json',
        ],
        'accept_whitelist' => [
            'Kemkes\\RSOnline\\V1\\Rpc\\Referensi\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
                2 => 'application/*+json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\Pasien\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DiagnosaPasien\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanSDM\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanAPD\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DataTempatTidur\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienMasuk\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKomorbid\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienNonKomorbid\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKeluar\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\KamarSimrsRsOnline\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/hal+json',
                2 => 'application/json',
            ],
        ],
        'content_type_whitelist' => [
            'Kemkes\\RSOnline\\V1\\Rpc\\Referensi\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\Pasien\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DiagnosaPasien\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanSDM\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DataKebutuhanAPD\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\DataTempatTidur\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienMasuk\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKomorbid\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienNonKomorbid\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\RekapPasienKeluar\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
            'Kemkes\\RSOnline\\V1\\Rest\\KamarSimrsRsOnline\\Controller' => [
                0 => 'application/vnd.kemkes-rsonline.v1+json',
                1 => 'application/json',
            ],
        ],
    ],
    'api-tools-hal' => [
        'metadata_map' => [
            \Kemkes\RSOnline\V1\Rest\Pasien\PasienEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.pasien',
                'route_identifier_name' => 'pasien_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\RSOnline\V1\Rest\Pasien\PasienCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.pasien',
                'route_identifier_name' => 'pasien_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.diagnosa-pasien',
                'route_identifier_name' => 'diagnosa_pasien_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\RSOnline\V1\Rest\DiagnosaPasien\DiagnosaPasienCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.diagnosa-pasien',
                'route_identifier_name' => 'diagnosa_pasien_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.data-kebutuhan-sdm',
                'route_identifier_name' => 'data_kebutuhan_sdm_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM\DataKebutuhanSDMCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.data-kebutuhan-sdm',
                'route_identifier_name' => 'data_kebutuhan_sdm_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.data-kebutuhan-apd',
                'route_identifier_name' => 'data_kebutuhan_apd_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\RSOnline\V1\Rest\DataKebutuhanAPD\DataKebutuhanAPDCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.data-kebutuhan-apd',
                'route_identifier_name' => 'data_kebutuhan_apd_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.data-tempat-tidur',
                'route_identifier_name' => 'data_tempat_tidur_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializableHydrator::class,
            ],
            \Kemkes\RSOnline\V1\Rest\DataTempatTidur\DataTempatTidurCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.data-tempat-tidur',
                'route_identifier_name' => 'data_tempat_tidur_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-masuk',
                'route_identifier_name' => 'rekap_pasien_masuk_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializable::class,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienMasuk\RekapPasienMasukCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-masuk',
                'route_identifier_name' => 'rekap_pasien_masuk_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-komorbid',
                'route_identifier_name' => 'rekap_pasien_komorbid_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializable::class,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid\RekapPasienKomorbidCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-komorbid',
                'route_identifier_name' => 'rekap_pasien_komorbid_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-non-komorbid',
                'route_identifier_name' => 'rekap_pasien_non_komorbid_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializable::class,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid\RekapPasienNonKomorbidCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-non-komorbid',
                'route_identifier_name' => 'rekap_pasien_non_komorbid_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-keluar',
                'route_identifier_name' => 'rekap_pasien_keluar_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializable::class,
            ],
            \Kemkes\RSOnline\V1\Rest\RekapPasienKeluar\RekapPasienKeluarCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.rekap-pasien-keluar',
                'route_identifier_name' => 'rekap_pasien_keluar_id',
                'is_collection' => true,
            ],
            \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineEntity::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.kamar-simrs-rs-online',
                'route_identifier_name' => 'kamar_simrs_rs_online_id',
                'hydrator' => \Laminas\Hydrator\ArraySerializable::class,
            ],
            \Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline\KamarSimrsRsOnlineCollection::class => [
                'entity_identifier_name' => 'id',
                'route_name' => 'kemkes-rsonline.rest.kamar-simrs-rs-online',
                'route_identifier_name' => 'kamar_simrs_rs_online_id',
                'is_collection' => true,
            ],
        ],
    ],
    'controllers' => [
        'factories' => [
            'Kemkes\\RSOnline\\V1\\Rpc\\Referensi\\Controller' => \Kemkes\RSOnline\V1\Rpc\Referensi\ReferensiControllerFactory::class,
        ],
    ],
    'api-tools-rpc' => [
        'Kemkes\\RSOnline\\V1\\Rpc\\Referensi\\Controller' => [
            'service_name' => 'Referensi',
            'http_methods' => [
                0 => 'GET',
            ],
            'route_name' => 'kemkes-rsonline.rpc.referensi',
        ],
    ],
];
