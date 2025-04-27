<?php
namespace Pendaftaran\V1\Rpc\Fungsi;

class FungsiControllerFactory
{
    public function __invoke($controllers)
    {
        return new FungsiController($controllers);
    }
}
