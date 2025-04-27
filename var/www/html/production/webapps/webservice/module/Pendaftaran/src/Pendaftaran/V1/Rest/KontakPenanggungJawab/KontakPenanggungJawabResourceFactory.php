<?php

namespace Pendaftaran\V1\Rest\KontakPenanggungJawab;

class KontakPenanggungJawabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KontakPenanggungJawabResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
