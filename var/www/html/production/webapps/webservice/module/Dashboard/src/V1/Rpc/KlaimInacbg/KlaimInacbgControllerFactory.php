<?php
namespace Dashboard\V1\Rpc\KlaimInacbg;

class KlaimInacbgControllerFactory
{
    public function __invoke($controllers)
    {
        return new KlaimInacbgController($controllers);
    }
}
