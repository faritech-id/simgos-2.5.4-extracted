<?php
namespace Kemkes\IHS\V1\Rpc\Consent;

class ConsentControllerFactory
{
    public function __invoke($controllers)
    {
        return new ConsentController($controllers);
    }
}
