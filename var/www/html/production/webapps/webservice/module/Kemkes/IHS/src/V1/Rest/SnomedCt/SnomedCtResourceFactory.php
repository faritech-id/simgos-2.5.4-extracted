<?php
namespace Kemkes\IHS\V1\Rest\SnomedCt;

class SnomedCtResourceFactory
{
    public function __invoke($services)
    {
        return new SnomedCtResource();
    }
}
