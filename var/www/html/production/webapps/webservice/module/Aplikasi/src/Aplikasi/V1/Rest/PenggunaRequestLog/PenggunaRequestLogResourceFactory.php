<?php
namespace Aplikasi\V1\Rest\PenggunaRequestLog;

class PenggunaRequestLogResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenggunaRequestLogResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
