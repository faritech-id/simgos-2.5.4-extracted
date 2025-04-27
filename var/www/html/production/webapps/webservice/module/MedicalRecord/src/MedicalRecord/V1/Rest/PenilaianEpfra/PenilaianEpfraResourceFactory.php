<?php
namespace MedicalRecord\V1\Rest\PenilaianEpfra;

class PenilaianEpfraResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianEpfraResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
