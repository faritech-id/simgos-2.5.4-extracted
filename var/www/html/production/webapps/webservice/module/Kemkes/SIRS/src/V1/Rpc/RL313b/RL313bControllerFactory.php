<?php
namespace Kemkes\SIRS\V1\Rpc\RL313b;

class RL313bControllerFactory
{
    public function __invoke($controllers)
    {
        return new RL313bController($controllers);
    }
}
