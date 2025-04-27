<?php
namespace Kemkes\IHS\V1\Rpc\Observation;

class ObservationControllerFactory
{
    public function __invoke($controllers)
    {
        return new ObservationController($controllers);
    }
}
