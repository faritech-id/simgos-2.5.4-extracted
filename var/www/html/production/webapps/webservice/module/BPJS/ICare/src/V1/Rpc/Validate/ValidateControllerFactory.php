<?php
namespace BPJS\ICare\V1\Rpc\Validate;

class ValidateControllerFactory
{
    public function __invoke($controllers)
    {
        return new ValidateController($controllers);
    }
}
