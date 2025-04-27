<?php
namespace Aplikasi\V1\Rest\Modules;

class ModulesResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ModulesResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
