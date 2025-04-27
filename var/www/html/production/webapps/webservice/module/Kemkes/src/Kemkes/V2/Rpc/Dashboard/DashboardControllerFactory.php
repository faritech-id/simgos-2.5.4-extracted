<?php
namespace Kemkes\V2\Rpc\Dashboard;

class DashboardControllerFactory
{
    public function __invoke($controllers)
    {
        return new DashboardController($controllers);
    }
}
