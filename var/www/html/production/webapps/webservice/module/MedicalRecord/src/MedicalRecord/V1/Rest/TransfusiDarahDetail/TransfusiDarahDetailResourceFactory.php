<?php
namespace MedicalRecord\V1\Rest\TransfusiDarahDetail;

class TransfusiDarahDetailResourceFactory
{
    public function __invoke($services)
    {
        return new TransfusiDarahDetailResource();
    }
}
