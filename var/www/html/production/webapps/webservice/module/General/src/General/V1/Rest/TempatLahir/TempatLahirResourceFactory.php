<?php

namespace General\V1\Rest\TempatLahir;

class TempatLahirResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TempatLahirResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
