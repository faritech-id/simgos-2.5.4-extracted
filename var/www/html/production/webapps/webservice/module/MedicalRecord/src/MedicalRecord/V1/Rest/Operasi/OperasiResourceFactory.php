<?php
namespace MedicalRecord\V1\Rest\Operasi;

class OperasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OperasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
