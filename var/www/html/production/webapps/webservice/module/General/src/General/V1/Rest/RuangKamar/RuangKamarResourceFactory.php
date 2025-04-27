<?php

namespace General\V1\Rest\RuangKamar;

class RuangKamarResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuangKamarResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
