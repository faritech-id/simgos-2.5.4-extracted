<?php

namespace General\V1\Rest\TindakanRuangan;

class TindakanRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TindakanRuanganResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
