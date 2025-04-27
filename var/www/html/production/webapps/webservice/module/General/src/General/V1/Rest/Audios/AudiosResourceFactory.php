<?php
namespace General\V1\Rest\Audios;

class AudiosResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AudiosResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
