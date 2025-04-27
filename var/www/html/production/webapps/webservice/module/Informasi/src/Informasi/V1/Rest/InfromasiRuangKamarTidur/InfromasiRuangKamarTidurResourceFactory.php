<?php

namespace Informasi\V1\Rest\InfromasiRuangKamarTidur;

class InfromasiRuangKamarTidurResourceFactory
{
    public function __invoke($services)
    {
        $obj = new InfromasiRuangKamarTidurResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
