<?php
namespace General\V1\Rest\DistribusiTarifTindakan;

class DistribusiTarifTindakanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DistribusiTarifTindakanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
