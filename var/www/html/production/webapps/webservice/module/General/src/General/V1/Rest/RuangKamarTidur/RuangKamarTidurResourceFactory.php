<?php

namespace General\V1\Rest\RuangKamarTidur;

class RuangKamarTidurResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuangKamarTidurResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
