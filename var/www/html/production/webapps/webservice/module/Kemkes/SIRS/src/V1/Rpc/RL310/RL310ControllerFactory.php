<?php
namespace Kemkes\SIRS\V1\Rpc\RL310;

class RL310ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL310Controller($controllers);
    }
}
