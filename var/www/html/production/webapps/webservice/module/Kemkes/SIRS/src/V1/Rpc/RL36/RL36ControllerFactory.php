<?php
namespace Kemkes\SIRS\V1\Rpc\RL36;

class RL36ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL36Controller($controllers);
    }
}
