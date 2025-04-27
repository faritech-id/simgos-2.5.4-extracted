<?php
namespace BerkasKlaim\V1\Rpc\Berkas;

class BerkasControllerFactory
{
    public function __invoke($controllers)
    {
        return new BerkasController($controllers);
    }
}
