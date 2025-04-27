<?php
namespace Kemkes\IHS\V1\Rest\ParameterHasilToLoinc;

class ParameterHasilToLoincResourceFactory
{
    public function __invoke($services)
    {
        return new ParameterHasilToLoincResource();
    }
}
