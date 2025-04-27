<?php
namespace Kemkes\V2\Rpc\Siranap;

class SiranapControllerFactory
{
    public function __invoke($controllers)
    {
        return new SiranapController($controllers);
    }
}
