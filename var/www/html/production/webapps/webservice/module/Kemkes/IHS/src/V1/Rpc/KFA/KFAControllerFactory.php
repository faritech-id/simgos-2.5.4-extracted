<?php
namespace Kemkes\IHS\V1\Rpc\KFA;

class KFAControllerFactory
{
    public function __invoke($controllers)
    {
        return new KFAController($controllers);
    }
}
