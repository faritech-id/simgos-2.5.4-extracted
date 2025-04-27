<?php
namespace Kemkes\SIRS\V1\Rpc\RL13;

class RL13ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL13Controller($controllers);
    }
}
