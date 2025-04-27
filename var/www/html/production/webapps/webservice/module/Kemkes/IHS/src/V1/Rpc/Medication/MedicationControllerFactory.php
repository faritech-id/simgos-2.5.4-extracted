<?php
namespace Kemkes\IHS\V1\Rpc\Medication;

class MedicationControllerFactory
{
    public function __invoke($controllers)
    {
        return new MedicationController($controllers);
    }
}
