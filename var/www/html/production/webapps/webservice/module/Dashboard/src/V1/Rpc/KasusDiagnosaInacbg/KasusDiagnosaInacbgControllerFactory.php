<?php
namespace Dashboard\V1\Rpc\KasusDiagnosaInacbg;

class KasusDiagnosaInacbgControllerFactory
{
    public function __invoke($controllers)
    {
        return new KasusDiagnosaInacbgController($controllers);
    }
}
