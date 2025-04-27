<?php
namespace MedicalRecord\V1\Rest\PenilaianBarthelIndex;

class PenilaianBarthelIndexResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianBarthelIndexResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
