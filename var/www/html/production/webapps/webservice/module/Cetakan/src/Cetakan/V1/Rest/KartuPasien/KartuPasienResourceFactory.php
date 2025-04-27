<?php
namespace Cetakan\V1\Rest\KartuPasien;

class KartuPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KartuPasienResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
