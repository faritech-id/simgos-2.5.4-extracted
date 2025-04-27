<?php
namespace Layanan\V1\Rest\PasienMeninggal;

class PasienMeninggalResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PasienMeninggalResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
