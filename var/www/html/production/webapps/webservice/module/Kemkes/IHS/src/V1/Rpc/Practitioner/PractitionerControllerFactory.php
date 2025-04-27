<?php
namespace Kemkes\IHS\V1\Rpc\Practitioner;

class PractitionerControllerFactory
{
    public function __invoke($controllers)
    {
        return new PractitionerController($controllers);
    }
}
