<?php
namespace Kemkes\IHS\V1\Rpc\Specimen;

class SpecimenControllerFactory
{
    public function __invoke($controllers)
    {
        return new SpecimenController($controllers);
    }
}
