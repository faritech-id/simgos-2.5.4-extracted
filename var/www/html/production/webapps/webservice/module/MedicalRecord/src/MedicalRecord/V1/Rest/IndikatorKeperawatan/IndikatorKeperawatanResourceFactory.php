<?php

namespace MedicalRecord\V1\Rest\IndikatorKeperawatan;

class IndikatorKeperawatanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new IndikatorKeperawatanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
