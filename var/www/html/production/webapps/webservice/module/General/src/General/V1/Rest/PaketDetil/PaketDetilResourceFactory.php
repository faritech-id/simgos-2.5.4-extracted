<?php
namespace General\V1\Rest\PaketDetil;

class PaketDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PaketDetilResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
