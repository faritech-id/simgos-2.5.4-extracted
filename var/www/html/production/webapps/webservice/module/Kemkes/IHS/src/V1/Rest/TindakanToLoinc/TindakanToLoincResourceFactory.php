<?php
namespace Kemkes\IHS\V1\Rest\TindakanToLoinc;

class TindakanToLoincResourceFactory
{
    public function __invoke($services)
    {
        return new TindakanToLoincResource();
    }
}
