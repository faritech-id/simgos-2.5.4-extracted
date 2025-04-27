<?php

namespace INACBGService\V1\Rest\Map;

class MapResourceFactory
{
    public function __invoke($services)
    {
        $obj = new MapResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
