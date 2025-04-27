<?php
namespace Kemkes\IHS\V1\Rpc\Encounter;

class EncounterControllerFactory
{
    public function __invoke($controllers)
    {
        return new EncounterController($controllers);
    }
}
