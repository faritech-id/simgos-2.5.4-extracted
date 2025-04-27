<?php
namespace MedicalRecord\V1\Rest\TransfusiDarah;

class TransfusiDarahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TransfusiDarahResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
