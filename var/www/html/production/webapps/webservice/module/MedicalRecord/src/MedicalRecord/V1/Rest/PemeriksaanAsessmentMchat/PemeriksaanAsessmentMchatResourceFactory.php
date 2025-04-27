<?php

namespace MedicalRecord\V1\Rest\PemeriksaanAsessmentMchat;

class PemeriksaanAsessmentMchatResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemeriksaanAsessmentMchatResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
