<?php
namespace Dashboard\V1\Rpc\KasusDiagnosa;

class KasusDiagnosaControllerFactory
{
    public function __invoke($controllers)
    {
        return new KasusDiagnosaController($controllers);
    }
}
