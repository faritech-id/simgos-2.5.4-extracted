<?php
namespace Plugins\V2\Rest\RequestReport;

class RequestReportResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RequestReportResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
