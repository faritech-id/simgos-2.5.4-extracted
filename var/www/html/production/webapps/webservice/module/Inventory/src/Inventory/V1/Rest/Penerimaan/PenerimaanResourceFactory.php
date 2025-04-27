<?php

namespace Inventory\V1\Rest\Penerimaan;

class PenerimaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenerimaanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
