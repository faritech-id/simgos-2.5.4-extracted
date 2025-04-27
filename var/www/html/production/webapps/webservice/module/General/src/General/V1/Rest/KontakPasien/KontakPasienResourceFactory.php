<?php
namespace General\V1\Rest\KontakPasien;

class KontakPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KontakPasienResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
