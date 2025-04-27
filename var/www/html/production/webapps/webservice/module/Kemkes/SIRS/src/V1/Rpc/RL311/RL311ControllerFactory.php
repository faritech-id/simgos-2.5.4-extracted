<?php
namespace Kemkes\SIRS\V1\Rpc\RL311;

class RL311ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL311Controller($controllers);
    }
}
