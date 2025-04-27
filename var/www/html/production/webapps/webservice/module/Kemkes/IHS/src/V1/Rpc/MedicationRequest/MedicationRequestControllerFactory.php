<?php
namespace Kemkes\IHS\V1\Rpc\MedicationRequest;

class MedicationRequestControllerFactory
{
    public function __invoke($controllers)
    {
        return new MedicationRequestController($controllers);
    }
}
