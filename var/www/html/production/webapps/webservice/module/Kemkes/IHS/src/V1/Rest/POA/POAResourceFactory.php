<?php
namespace Kemkes\IHS\V1\Rest\POA;

class POAResourceFactory
{
    public function __invoke($services)
    {
        return new POAResource();
    }
}
