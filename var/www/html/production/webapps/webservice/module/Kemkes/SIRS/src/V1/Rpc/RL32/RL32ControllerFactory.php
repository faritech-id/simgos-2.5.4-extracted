<?php
namespace Kemkes\SIRS\V1\Rpc\RL32;

class RL32ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL32Controller($controllers);
    }
}
