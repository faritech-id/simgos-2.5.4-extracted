<?php
namespace Kemkes\SIRS\V1\Rpc\RL2;

class RL2ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL2Controller($controllers);
    }
}
