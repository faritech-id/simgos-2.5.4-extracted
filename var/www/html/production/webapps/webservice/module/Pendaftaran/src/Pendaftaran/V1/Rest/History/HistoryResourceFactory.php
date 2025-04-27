<?php
namespace Pendaftaran\V1\Rest\History;

class HistoryResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HistoryResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
