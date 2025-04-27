<?php
namespace General\V1\Rest\DistribusiTarifPaket;

class DistribusiTarifPaketResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DistribusiTarifPaketResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
