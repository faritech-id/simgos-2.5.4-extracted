<?php
namespace Kemkes\IHS\V1\Rest\TypeCodeReference;

class TypeCodeReferenceResourceFactory
{
    public function __invoke($services)
    {
        return new TypeCodeReferenceResource();
    }
}
