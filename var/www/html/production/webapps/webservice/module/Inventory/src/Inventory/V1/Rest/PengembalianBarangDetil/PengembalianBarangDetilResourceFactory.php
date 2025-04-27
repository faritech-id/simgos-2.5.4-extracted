<?php

namespace Inventory\V1\Rest\PengembalianBarangDetil;

class PengembalianBarangDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PengembalianBarangDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
