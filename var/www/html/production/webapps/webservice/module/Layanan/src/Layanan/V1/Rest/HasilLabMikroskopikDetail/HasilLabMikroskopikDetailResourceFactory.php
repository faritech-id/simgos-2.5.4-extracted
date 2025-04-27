<?php
namespace Layanan\V1\Rest\HasilLabMikroskopikDetail;

class HasilLabMikroskopikDetailResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabMikroskopikDetailResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
