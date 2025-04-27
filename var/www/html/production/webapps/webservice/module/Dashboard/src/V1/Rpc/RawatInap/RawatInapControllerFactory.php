<?php
namespace Dashboard\V1\Rpc\RawatInap;

class RawatInapControllerFactory
{
    public function __invoke($controllers)
    {
        return new RawatInapController($controllers);
    }
}
