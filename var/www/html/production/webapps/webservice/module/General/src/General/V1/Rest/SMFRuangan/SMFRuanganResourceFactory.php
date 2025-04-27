<?php

namespace General\V1\Rest\SMFRuangan;

class SMFRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new SMFRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
