<?php
namespace Kemkes\SIRS\V1\Rpc\RL12;

class RL12ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL12Controller($controllers);
    }
}
