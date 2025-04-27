<?php

namespace General\V1\Rest\TindakanPaket;

class TindakanPaketResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TindakanPaketResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
