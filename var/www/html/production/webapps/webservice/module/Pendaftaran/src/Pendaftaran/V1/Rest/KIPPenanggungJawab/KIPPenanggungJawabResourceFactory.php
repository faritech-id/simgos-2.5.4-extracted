<?php

namespace Pendaftaran\V1\Rest\KIPPenanggungJawab;

class KIPPenanggungJawabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KIPPenanggungJawabResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
