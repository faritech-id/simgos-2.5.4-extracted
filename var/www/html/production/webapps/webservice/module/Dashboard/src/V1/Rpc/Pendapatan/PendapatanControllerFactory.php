<?php
namespace Dashboard\V1\Rpc\Pendapatan;

class PendapatanControllerFactory
{
    public function __invoke($controllers)
    {
        return new PendapatanController($controllers);
    }
}
