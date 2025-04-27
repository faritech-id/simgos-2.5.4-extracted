<?php
namespace Kemkes\IHS\V1\Rpc\KnowYourCustomer;

class KnowYourCustomerControllerFactory
{
    public function __invoke($controllers)
    {
        return new KnowYourCustomerController($controllers);
    }
}
