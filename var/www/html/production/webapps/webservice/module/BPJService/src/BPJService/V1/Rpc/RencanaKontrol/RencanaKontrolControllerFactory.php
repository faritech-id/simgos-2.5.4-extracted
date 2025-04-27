<?php
namespace BPJService\V1\Rpc\RencanaKontrol;

class RencanaKontrolControllerFactory
{
    public function __invoke($controllers)
    {
        $bpjs = $controllers->get('BPJService\Service'); 
        return new RencanaKontrolController($bpjs);
    }
}
