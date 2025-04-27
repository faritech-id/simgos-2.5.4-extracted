<?php
namespace Dashboard\V1\Rpc\Indikator;

class IndikatorControllerFactory
{
    public function __invoke($controllers)
    {
        return new IndikatorController($controllers);
    }
}
