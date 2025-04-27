<?php
namespace General\V1\Rest\GroupReferensiKelas;

class GroupReferensiKelasResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GroupReferensiKelasResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
