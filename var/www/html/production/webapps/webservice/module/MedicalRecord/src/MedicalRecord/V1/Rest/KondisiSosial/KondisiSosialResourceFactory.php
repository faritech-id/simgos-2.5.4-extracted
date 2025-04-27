<?php
namespace MedicalRecord\V1\Rest\KondisiSosial;

class KondisiSosialResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KondisiSosialResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
