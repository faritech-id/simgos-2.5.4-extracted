<?php

namespace INACBGService\V1\Rest\Grouping;

class GroupingResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GroupingResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
