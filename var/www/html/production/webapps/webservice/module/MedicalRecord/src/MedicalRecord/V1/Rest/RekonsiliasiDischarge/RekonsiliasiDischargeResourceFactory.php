<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiDischarge;

class RekonsiliasiDischargeResourceFactory
{
    public function __invoke($services)
    {
        return new RekonsiliasiDischargeResource();
    }
}
