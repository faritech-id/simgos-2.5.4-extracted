<?php
namespace MedicalRecord\V1\Rest\TindakanMMPI;

class TindakanMMPIResourceFactory
{
    public function __invoke($services)
    {
        $obj= new TindakanMMPIResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
