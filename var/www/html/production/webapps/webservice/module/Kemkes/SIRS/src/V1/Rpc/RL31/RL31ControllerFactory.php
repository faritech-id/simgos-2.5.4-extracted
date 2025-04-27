<?php
namespace Kemkes\SIRS\V1\Rpc\RL31;

class RL31ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL31Controller($controllers);
    }
}
