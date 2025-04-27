<?php
namespace Aplikasi\V1\Rest\InfoTeks;

class InfoTeksResourceFactory
{
    public function __invoke($services)
    {
        $obj = new InfoTeksResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
