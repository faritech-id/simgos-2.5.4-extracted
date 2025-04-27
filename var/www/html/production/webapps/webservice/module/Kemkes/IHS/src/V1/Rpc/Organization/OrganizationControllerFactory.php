<?php
namespace Kemkes\IHS\V1\Rpc\Organization;

class OrganizationControllerFactory
{
    public function __invoke($controllers)
    {
        return new OrganizationController($controllers);
    }
}
