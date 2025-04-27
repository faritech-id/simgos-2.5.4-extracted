<?php
namespace Kemkes\SIRS\V1\Rpc\RL39;

class RL39ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL39Controller($controllers);
    }
}
