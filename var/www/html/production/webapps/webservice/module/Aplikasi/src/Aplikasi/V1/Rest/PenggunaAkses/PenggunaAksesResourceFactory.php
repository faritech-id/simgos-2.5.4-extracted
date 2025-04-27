<?php
namespace Aplikasi\V1\Rest\PenggunaAkses;

class PenggunaAksesResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenggunaAksesResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
