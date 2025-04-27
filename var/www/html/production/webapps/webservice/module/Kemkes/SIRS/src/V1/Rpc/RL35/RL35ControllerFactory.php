<?php
namespace Kemkes\SIRS\V1\Rpc\RL35;

class RL35ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL35Controller($controllers);
    }
}
