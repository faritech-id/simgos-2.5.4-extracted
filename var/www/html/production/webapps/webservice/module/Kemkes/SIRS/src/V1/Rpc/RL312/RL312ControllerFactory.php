<?php
namespace Kemkes\SIRS\V1\Rpc\RL312;

class RL312ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL312Controller($controllers);
    }
}
