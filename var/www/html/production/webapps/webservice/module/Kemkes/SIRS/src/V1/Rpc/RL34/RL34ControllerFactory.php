<?php
namespace Kemkes\SIRS\V1\Rpc\RL34;

class RL34ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL34Controller($controllers);
    }
}
