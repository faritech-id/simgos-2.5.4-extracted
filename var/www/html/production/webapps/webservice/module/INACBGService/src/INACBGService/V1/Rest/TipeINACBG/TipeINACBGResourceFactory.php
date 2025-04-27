<?php

namespace INACBGService\V1\Rest\TipeINACBG;

class TipeINACBGResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TipeINACBGResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
