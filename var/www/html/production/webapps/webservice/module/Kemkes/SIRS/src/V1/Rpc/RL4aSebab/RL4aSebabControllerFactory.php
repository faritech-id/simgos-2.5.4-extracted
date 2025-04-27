<?php
namespace Kemkes\SIRS\V1\Rpc\RL4aSebab;

class RL4aSebabControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL4aSebabController($controllers);
    }
}
