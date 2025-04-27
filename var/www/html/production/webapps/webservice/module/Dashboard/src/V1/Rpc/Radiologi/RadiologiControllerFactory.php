<?php
namespace Dashboard\V1\Rpc\Radiologi;

class RadiologiControllerFactory
{
    public function __invoke($controllers)
    {
        return new RadiologiController($controllers);
    }
}
