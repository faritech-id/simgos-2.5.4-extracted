<?php
namespace MedicalRecord\V1\Rest\PemantuanHDIntradialitik;

class PemantuanHDIntradialitikResourceFactory
{
    public function __invoke($services)
    {
        return new PemantuanHDIntradialitikResource();
    }
}
