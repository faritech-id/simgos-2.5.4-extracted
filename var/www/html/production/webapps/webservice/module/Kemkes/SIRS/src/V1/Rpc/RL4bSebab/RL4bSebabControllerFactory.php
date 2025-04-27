<?php
namespace Kemkes\SIRS\V1\Rpc\RL4bSebab;

class RL4bSebabControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL4bSebabController($controllers);
    }
}
