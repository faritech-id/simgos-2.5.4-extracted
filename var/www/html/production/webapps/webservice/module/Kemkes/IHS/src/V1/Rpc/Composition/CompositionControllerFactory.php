<?php
namespace Kemkes\IHS\V1\Rpc\Composition;

class CompositionControllerFactory
{
    public function __invoke($controllers)
    {
        return new CompositionController($controllers);
    }
}
