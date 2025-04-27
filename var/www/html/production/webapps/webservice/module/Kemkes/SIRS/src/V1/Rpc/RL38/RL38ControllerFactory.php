<?php
namespace Kemkes\SIRS\V1\Rpc\RL38;

class RL38ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL38Controller($controllers);
    }
}
