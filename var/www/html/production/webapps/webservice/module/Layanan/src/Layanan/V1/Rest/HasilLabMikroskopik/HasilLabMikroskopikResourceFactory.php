<?php
namespace Layanan\V1\Rest\HasilLabMikroskopik;

class HasilLabMikroskopikResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabMikroskopikResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
