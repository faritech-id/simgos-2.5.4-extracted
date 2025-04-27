<?php
namespace Kemkes\IHS\V1\Rest\Loinc;

class LoincResourceFactory
{
    public function __invoke($services)
    {
        return new LoincResource();
    }
}
