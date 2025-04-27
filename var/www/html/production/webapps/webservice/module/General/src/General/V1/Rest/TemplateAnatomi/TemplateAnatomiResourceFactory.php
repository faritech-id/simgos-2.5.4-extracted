<?php
namespace General\V1\Rest\TemplateAnatomi;

class TemplateAnatomiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TemplateAnatomiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}


