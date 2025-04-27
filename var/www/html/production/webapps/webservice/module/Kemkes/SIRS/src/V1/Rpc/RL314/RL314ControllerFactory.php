<?php
namespace Kemkes\SIRS\V1\Rpc\RL314;

class RL314ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL314Controller($controllers);
    }
}
