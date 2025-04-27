<?php
namespace General\V1\Rest\AntibiotikBakteri;

class AntibiotikBakteriResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AntibiotikBakteriResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
