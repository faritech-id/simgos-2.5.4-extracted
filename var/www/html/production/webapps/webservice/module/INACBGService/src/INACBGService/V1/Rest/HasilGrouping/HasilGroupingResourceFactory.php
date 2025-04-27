<?php

namespace INACBGService\V1\Rest\HasilGrouping;

class HasilGroupingResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilGroupingResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
