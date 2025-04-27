<?php
namespace Kemkes\SIRS\V1\Rpc\RL315;

class RL315ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL315Controller($controllers);
    }
}
