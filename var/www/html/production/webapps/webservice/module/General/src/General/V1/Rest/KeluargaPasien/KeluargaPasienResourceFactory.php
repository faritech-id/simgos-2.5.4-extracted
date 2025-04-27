<?php
namespace General\V1\Rest\KeluargaPasien;

class KeluargaPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KeluargaPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
