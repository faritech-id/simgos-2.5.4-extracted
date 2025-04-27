<?php
namespace Inventory\V1\Rest\Barang;

class BarangResourceFactory
{
    public function __invoke($services)
    {
        $obj = new BarangResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
