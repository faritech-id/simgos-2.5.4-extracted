<?php
namespace TTE\V1\Rpc\Sign;

class SignControllerFactory
{
    public function __invoke($controllers)
    {
        return new SignController($controllers);
    }
}
