<?php

namespace General\V1\Rest\RuanganLaboratorium;

class RuanganLaboratoriumResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganLaboratoriumResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
