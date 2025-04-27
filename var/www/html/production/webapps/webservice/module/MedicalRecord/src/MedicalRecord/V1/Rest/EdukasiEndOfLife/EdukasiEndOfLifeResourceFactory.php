<?php
namespace MedicalRecord\V1\Rest\EdukasiEndOfLife;

class EdukasiEndOfLifeResourceFactory
{
    public function __invoke($services)
    {
        $obj = new EdukasiEndOfLifeResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
