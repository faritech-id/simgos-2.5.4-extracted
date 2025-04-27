<?php
namespace General\V1\Rest\PenjaminSubSpesialistik;

class PenjaminSubSpesialistikResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenjaminSubSpesialistikResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
