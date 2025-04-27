<?php

namespace Layanan\V1\Rest\JasaTuslahFarmasi;

class JasaTuslahFarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JasaTuslahFarmasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
