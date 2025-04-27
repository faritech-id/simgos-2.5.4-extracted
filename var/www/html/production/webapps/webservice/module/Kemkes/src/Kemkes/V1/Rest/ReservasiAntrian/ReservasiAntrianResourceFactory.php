<?php

namespace Kemkes\V1\Rest\ReservasiAntrian;

class ReservasiAntrianResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ReservasiAntrianResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
