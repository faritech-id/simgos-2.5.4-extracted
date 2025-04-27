<?php
namespace Informasi\V1\Rest\MonitoringSikepo;

class MonitoringSikepoResourceFactory
{
    public function __invoke($services)
    {
        return new MonitoringSikepoResource();
    }
}
