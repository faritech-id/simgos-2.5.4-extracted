<?php
namespace General\V1\Rest\Diagnosa;

class DiagnosaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiagnosaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
