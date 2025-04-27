<?php
namespace Kemkes\SIRS\V1\Rpc\RL53;

class RL53ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL53Controller($controllers);
    }
}
