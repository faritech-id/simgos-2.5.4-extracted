<?php
namespace Kemkes\IHS\V1\Rpc\Procedure;

class ProcedureControllerFactory
{
    public function __invoke($controllers)
    {
        return new ProcedureController($controllers);
    }
}
