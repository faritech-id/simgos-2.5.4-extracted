<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiAdmisiDetil;

class RekonsiliasiAdmisiDetilResourceFactory
{
    public function __invoke($services)
    {
        return new RekonsiliasiAdmisiDetilResource();
    }
}
