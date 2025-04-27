<?php
namespace Kemkes\IHS\V1\Rpc\Location;

class LocationControllerFactory
{
    public function __invoke($controllers)
    {
        return new LocationController($controllers);
    }
}
