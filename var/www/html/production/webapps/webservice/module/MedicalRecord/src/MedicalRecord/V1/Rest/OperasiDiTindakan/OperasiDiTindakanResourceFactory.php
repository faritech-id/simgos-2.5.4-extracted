<?php
namespace MedicalRecord\V1\Rest\OperasiDiTindakan;

class OperasiDiTindakanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OperasiDiTindakanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
