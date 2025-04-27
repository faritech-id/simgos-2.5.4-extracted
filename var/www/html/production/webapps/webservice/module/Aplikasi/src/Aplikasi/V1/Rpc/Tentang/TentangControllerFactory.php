<?php
namespace Aplikasi\V1\Rpc\Tentang;

class TentangControllerFactory
{
    public function __invoke($controllers)
    {
        return new TentangController($controllers);
    }
}
