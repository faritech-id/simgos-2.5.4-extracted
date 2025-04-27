<?php
namespace Kemkes\SIRS\V1\Rpc\RL4a;

class RL4aControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL4aController($controllers);
    }
}
