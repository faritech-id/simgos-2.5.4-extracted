<?php
namespace MedicalRecord\V1\Rest\EdukasiEmergency;

class EdukasiEmergencyResourceFactory
{
    public function __invoke($services)
    {
        $obj = new EdukasiEmergencyResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
