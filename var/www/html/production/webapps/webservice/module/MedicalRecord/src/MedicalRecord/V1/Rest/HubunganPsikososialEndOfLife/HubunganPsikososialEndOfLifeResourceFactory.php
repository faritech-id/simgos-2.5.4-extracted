<?php
namespace MedicalRecord\V1\Rest\HubunganPsikososialEndOfLife;

class HubunganPsikososialEndOfLifeResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HubunganPsikososialEndOfLifeResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
