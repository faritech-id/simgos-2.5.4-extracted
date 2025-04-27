<?php
namespace Pegawai\V1\Rest\StrSip;

class StrSipResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StrSipResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
