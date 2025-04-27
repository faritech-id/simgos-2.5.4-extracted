<?php
namespace Kemkes\IHS\V1\Rest\BarangToPoaPov;

class BarangToPoaPovResourceFactory
{
    public function __invoke($services)
    {
        return new BarangToPoaPovResource();
    }
}
