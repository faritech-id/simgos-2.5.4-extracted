<?php
namespace Layanan\V1\Rest\PetugasTindakanMedis;

class PetugasTindakanMedisResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PetugasTindakanMedisResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
