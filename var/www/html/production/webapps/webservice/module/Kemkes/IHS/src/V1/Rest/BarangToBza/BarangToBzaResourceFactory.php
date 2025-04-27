<?php
namespace Kemkes\IHS\V1\Rest\BarangToBza;

class BarangToBzaResourceFactory
{
    public function __invoke($services)
    {
        return new BarangToBzaResource();
    }
}
