<?php
namespace BPJService\V1\Rpc\LPK;

class LPKControllerFactory
{
    public function __invoke($controllers)
    {
        $bpjs = $controllers->get('BPJService\Service'); 
        return new LPKController($bpjs);
    }
}
