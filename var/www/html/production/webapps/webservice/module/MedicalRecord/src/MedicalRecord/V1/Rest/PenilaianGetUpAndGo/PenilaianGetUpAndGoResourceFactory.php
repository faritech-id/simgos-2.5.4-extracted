<?php
namespace MedicalRecord\V1\Rest\PenilaianGetUpAndGo;

class PenilaianGetUpAndGoResourceFactory
{
    public function __invoke($services)
    {
		$obj = new PenilaianGetUpAndGoResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
