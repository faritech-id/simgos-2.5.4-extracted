<?php

namespace Inventory\V1\Rest\PenerimaanBarangDetil;

class PenerimaanBarangDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenerimaanBarangDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
