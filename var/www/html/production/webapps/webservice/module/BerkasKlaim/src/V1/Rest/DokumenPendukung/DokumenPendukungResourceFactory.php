<?php
namespace BerkasKlaim\V1\Rest\DokumenPendukung;

class DokumenPendukungResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DokumenPendukungResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
