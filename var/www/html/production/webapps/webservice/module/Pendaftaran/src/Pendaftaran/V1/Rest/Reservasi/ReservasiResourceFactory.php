<?php

namespace Pendaftaran\V1\Rest\Reservasi;

class ReservasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ReservasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
