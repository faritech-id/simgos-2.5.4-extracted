<?php
namespace General\V1\Rest\NilaiRujukanLab;

class NilaiRujukanLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new NilaiRujukanLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
