<?php
namespace Kemkes\SIRS\V1\Rpc\RL51;

class RL51ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL51Controller($controllers);
    }
}
