<?php
namespace BPJService\V1\Rpc\PRB;

class PRBControllerFactory
{
    public function __invoke($controllers)
    {
        $bpjs = $controllers->get('BPJService\Service'); 
        return new PRBController($bpjs);
    }
}
