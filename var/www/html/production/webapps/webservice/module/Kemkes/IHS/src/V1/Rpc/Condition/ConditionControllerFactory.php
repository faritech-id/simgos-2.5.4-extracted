<?php
namespace Kemkes\IHS\V1\Rpc\Condition;

class ConditionControllerFactory
{
    public function __invoke($controllers)
    {
        return new ConditionController($controllers);
    }
}
