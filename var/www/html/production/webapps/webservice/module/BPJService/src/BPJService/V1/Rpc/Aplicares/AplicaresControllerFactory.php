<?php
namespace BPJService\V1\Rpc\Aplicares;

class AplicaresControllerFactory
{
    public function __invoke($controllers)
    {
        return new AplicaresController($controllers);
    }
}
