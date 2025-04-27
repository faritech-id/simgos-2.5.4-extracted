<?php
namespace Kemkes\SIRS\V1\Rpc\RL33;

class RL33ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL33Controller($controllers);
    }
}
