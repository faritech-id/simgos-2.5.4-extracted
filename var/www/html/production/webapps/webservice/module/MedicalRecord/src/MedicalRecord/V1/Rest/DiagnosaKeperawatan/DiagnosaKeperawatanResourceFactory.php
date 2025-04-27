<?php

namespace MedicalRecord\V1\Rest\DiagnosaKeperawatan;

class DiagnosaKeperawatanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiagnosaKeperawatanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
