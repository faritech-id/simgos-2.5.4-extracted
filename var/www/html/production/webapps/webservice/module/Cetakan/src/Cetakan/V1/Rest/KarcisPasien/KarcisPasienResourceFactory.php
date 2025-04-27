<?php
namespace Cetakan\V1\Rest\KarcisPasien;

class KarcisPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KarcisPasienResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
