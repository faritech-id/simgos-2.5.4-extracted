<?php

namespace INACBGService\V1\Rest\ListProcedure;

class ListProcedureResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ListProcedureResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
