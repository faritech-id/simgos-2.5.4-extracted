<?php
namespace Kemkes\SIRS\V1\Rpc\RL4b;

class RL4bControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL4bController($controllers);
    }
}
