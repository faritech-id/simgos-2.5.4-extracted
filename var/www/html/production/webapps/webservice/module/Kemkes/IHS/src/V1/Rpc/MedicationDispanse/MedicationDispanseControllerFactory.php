<?php
namespace Kemkes\IHS\V1\Rpc\MedicationDispanse;

class MedicationDispanseControllerFactory
{
    public function __invoke($controllers)
    {
        return new MedicationDispanseController($controllers);
    }
}
