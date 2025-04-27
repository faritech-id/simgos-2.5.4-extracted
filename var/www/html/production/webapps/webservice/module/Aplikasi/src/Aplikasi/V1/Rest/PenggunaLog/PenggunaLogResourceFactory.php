<?php
namespace Aplikasi\V1\Rest\PenggunaLog;

class PenggunaLogResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenggunaLogResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
