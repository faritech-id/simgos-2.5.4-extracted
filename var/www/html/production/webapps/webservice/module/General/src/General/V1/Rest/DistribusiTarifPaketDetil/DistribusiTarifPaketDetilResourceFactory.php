<?php
namespace General\V1\Rest\DistribusiTarifPaketDetil;

class DistribusiTarifPaketDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DistribusiTarifPaketDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
