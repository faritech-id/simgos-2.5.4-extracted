<?php
namespace Kemkes\SIRS\V1\Rpc\RL313;

class RL313ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL313Controller($controllers);
    }
}
