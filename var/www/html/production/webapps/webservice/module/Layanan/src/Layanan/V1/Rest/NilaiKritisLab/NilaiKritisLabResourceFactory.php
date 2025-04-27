<?php

namespace Layanan\V1\Rest\NilaiKritisLab;

class NilaiKritisLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new NilaiKritisLabResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
