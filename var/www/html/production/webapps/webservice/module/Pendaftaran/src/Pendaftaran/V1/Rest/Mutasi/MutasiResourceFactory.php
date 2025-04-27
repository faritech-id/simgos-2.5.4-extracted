<?php
namespace Pendaftaran\V1\Rest\Mutasi;

class MutasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new MutasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
