<?php
namespace Dashboard\V1\Rpc\Laboratorium;

class LaboratoriumControllerFactory
{
    public function __invoke($controllers)
    {
        return new LaboratoriumController($controllers);
    }
}
