<?php
namespace Kemkes\SIRS\V1\Rpc\RL37;

class RL37ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL37Controller($controllers);
    }
}
