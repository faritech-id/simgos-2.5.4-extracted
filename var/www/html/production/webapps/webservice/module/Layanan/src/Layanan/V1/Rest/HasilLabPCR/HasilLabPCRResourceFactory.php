<?php
namespace Layanan\V1\Rest\HasilLabPCR;

class HasilLabPCRResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabPCRResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
