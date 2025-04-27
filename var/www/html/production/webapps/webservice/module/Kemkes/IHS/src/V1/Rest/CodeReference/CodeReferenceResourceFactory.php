<?php
namespace Kemkes\IHS\V1\Rest\CodeReference;

class CodeReferenceResourceFactory
{
    public function __invoke($services)
    {
        return new CodeReferenceResource();
    }
}
