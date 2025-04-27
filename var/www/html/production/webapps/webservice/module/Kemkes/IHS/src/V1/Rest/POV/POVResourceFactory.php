<?php
namespace Kemkes\IHS\V1\Rest\POV;

class POVResourceFactory
{
    public function __invoke($services)
    {
        return new POVResource();
    }
}
