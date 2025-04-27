<?php

namespace General\V1\Rest\Videos;

class VideosResourceFactory
{
    public function __invoke($services)
    {
        $obj = new VideosResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
