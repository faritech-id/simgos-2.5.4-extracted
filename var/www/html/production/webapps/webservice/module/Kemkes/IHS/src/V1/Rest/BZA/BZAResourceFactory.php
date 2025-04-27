<?php
namespace Kemkes\IHS\V1\Rest\BZA;

class BZAResourceFactory
{
    public function __invoke($services)
    {
        return new BZAResource();
    }
}
