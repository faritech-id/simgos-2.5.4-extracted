<?php
namespace Layanan\V1\Rest\PermintaanDarahDetail;

class PermintaanDarahDetailResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PermintaanDarahDetailResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
