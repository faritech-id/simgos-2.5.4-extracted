<?php
namespace Kemkes\RSOnline\V1\Rest\DataTempatTidur;

class DataTempatTidurResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DataTempatTidurResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
