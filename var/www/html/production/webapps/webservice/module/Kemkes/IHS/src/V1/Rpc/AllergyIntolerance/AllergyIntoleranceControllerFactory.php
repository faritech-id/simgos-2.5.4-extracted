<?php
namespace Kemkes\IHS\V1\Rpc\AllergyIntolerance;

class AllergyIntoleranceControllerFactory
{
    public function __invoke($controllers)
    {
        return new AllergyIntoleranceController($controllers);
    }
}
