<?php

namespace Inventory\V1\Rest\Kategori;

class KategoriResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KategoriResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
