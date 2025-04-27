<?php
namespace BerkasKlaim\V1\Rest\PatologiAnatomiDetil;

class PatologiAnatomiDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PatologiAnatomiDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
