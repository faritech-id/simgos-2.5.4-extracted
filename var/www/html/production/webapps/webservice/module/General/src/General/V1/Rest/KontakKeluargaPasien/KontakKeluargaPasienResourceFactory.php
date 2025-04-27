<?php
namespace General\V1\Rest\KontakKeluargaPasien;

class KontakKeluargaPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KontakKeluargaPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
