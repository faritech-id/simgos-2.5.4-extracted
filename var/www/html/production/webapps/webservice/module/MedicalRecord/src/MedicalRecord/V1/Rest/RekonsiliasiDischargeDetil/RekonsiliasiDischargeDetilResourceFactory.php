<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiDischargeDetil;

class RekonsiliasiDischargeDetilResourceFactory
{
    public function __invoke($services)
    {
        return new RekonsiliasiDischargeDetilResource();
    }
}
