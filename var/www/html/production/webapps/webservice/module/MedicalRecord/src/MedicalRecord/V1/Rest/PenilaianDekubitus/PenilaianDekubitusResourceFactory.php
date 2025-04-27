<?php
namespace MedicalRecord\V1\Rest\PenilaianDekubitus;

class PenilaianDekubitusResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianDekubitusResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
