<?php

namespace Layanan\V1\Rest\PemakaianBhpDetil;

class PemakaianBhpDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemakaianBhpDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
