<?php
namespace Aplikasi\V1\Rest\PenggunaAksesRuangan;

class PenggunaAksesRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenggunaAksesRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
