<?php
namespace Dashboard\V1\Rpc\KlaimIks;

class KlaimIksControllerFactory
{
    public function __invoke($controllers)
    {
        return new KlaimIksController($controllers);
    }
}
