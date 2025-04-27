<?php
namespace MedicalRecord\V1\Rest\TindakanAbci;

class TindakanAbciResourceFactory
{
    public function __invoke($services)
    {
        return new TindakanAbciResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
