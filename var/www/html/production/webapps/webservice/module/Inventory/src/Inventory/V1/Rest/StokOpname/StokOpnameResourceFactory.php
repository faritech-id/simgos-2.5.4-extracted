<?php

namespace Inventory\V1\Rest\StokOpname;

class StokOpnameResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StokOpnameResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
