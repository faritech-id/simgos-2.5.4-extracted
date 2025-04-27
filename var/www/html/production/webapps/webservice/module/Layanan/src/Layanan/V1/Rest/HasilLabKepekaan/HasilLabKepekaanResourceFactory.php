<?php
namespace Layanan\V1\Rest\HasilLabKepekaan;

class HasilLabKepekaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabKepekaanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
