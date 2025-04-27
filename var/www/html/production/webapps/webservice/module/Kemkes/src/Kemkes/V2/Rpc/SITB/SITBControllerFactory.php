<?php
namespace Kemkes\V2\Rpc\SITB;

class SITBControllerFactory
{
    public function __invoke($controllers)
    {
        return new SITBController($controllers);
    }
}
