<?php
namespace Kemkes\IHS\V1\Rpc\ServiceRequest;

class ServiceRequestControllerFactory
{
    public function __invoke($controllers)
    {
        return new ServiceRequestController($controllers);
    }
}
