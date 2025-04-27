<?php

namespace Layanan\V1\Rest\CatatanHasilLab;

class CatatanHasilLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new CatatanHasilLabResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
