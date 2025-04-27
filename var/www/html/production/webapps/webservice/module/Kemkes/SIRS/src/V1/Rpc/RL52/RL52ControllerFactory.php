<?php
namespace Kemkes\SIRS\V1\Rpc\RL52;

class RL52ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL52Controller($controllers);
    }
}
