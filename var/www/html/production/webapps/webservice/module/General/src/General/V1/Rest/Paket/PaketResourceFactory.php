<?php
namespace General\V1\Rest\Paket;

class PaketResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PaketResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
