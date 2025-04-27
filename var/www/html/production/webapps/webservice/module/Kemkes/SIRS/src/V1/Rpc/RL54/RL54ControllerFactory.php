<?php
namespace Kemkes\SIRS\V1\Rpc\RL54;

class RL54ControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL54Controller($controllers);
    }
}
