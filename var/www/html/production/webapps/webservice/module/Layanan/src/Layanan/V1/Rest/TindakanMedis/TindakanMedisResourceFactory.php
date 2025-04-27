<?php
namespace Layanan\V1\Rest\TindakanMedis;

class TindakanMedisResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TindakanMedisResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
