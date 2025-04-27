<?php
namespace Dashboard\V1\Rpc\Pengunjung;

class PengunjungControllerFactory
{
    public function __invoke($controllers)
    {
        return new PengunjungController($controllers);
    }
}
