<?php
namespace Dashboard\V1\Rpc\Penerimaan;

class PenerimaanControllerFactory
{
    public function __invoke($controllers)
    {
        return new PenerimaanController($controllers);
    }
}
