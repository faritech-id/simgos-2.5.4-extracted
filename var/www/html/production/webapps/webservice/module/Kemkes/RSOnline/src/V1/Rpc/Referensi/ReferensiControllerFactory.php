<?php
namespace Kemkes\RSOnline\V1\Rpc\Referensi;

class ReferensiControllerFactory
{
    public function __invoke($controllers)
    {
        return new ReferensiController($controllers);
    }
}
