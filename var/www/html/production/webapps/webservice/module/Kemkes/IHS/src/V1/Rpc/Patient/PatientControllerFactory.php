<?php
namespace Kemkes\IHS\V1\Rpc\Patient;

class PatientControllerFactory
{
    public function __invoke($controllers)
    {
        return new PatientController($controllers);
    }
}
