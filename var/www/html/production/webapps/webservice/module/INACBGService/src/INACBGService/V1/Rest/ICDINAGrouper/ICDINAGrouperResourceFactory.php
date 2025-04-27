<?php
namespace INACBGService\V1\Rest\ICDINAGrouper;

class ICDINAGrouperResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ICDINAGrouperResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
