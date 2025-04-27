<?php

namespace General\V1\Rest\StaffRuangan;

class StaffRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StaffRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
