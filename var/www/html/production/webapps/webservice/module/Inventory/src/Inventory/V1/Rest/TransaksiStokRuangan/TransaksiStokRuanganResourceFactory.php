<?php

namespace Inventory\V1\Rest\TransaksiStokRuangan;

class TransaksiStokRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TransaksiStokRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
