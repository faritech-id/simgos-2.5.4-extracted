<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiAdmisi;

class RekonsiliasiAdmisiResourceFactory
{
    public function __invoke($services)
    {
        return new RekonsiliasiAdmisiResource();
    }
}
