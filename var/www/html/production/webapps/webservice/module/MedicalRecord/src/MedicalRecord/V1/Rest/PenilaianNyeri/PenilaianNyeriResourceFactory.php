<?php
namespace MedicalRecord\V1\Rest\PenilaianNyeri;

class PenilaianNyeriResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianNyeriResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
