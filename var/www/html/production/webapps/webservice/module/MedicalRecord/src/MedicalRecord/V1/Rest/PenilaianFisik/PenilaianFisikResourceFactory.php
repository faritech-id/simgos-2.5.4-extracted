<?php
namespace MedicalRecord\V1\Rest\PenilaianFisik;

class PenilaianFisikResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianFisikResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
