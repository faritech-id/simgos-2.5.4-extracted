<?php

namespace MedicalRecord\V1\Rest\AsuhanKeperawatan;

class AsuhanKeperawatanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AsuhanKeperawatanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
