<?php
namespace Pendaftaran\V1\Rest\PenerimaanLayanan;

class PenerimaanLayananResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenerimaanLayananResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
