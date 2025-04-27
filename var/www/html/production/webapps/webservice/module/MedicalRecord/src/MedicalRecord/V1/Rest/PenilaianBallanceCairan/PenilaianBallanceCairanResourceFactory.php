<?php
namespace MedicalRecord\V1\Rest\PenilaianBallanceCairan;

class PenilaianBallanceCairanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianBallanceCairanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}