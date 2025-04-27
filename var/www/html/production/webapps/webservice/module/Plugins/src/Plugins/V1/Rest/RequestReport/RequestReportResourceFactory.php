<?php

namespace Plugins\V1\Rest\RequestReport;

class RequestReportResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RequestReportResource($services);
        $obj->setServiceManager($services);
        return $obj;
    }
}
