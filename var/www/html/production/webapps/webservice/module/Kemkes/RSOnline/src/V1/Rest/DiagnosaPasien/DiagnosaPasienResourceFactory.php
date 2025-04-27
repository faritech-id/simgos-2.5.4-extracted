<?php
namespace Kemkes\RSOnline\V1\Rest\DiagnosaPasien;

class DiagnosaPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiagnosaPasienResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
