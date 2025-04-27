<?php

namespace MedicalRecord\V1\Rest\VerifikasiCPPT;

class VerifikasiCPPTResourceFactory
{
    public function __invoke($services)
    {
        $obj = new VerifikasiCPPTResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
