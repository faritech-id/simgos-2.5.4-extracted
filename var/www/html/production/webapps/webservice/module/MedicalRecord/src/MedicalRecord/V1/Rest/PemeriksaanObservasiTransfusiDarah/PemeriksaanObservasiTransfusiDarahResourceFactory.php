<?php
namespace MedicalRecord\V1\Rest\PemeriksaanObservasiTransfusiDarah;

class PemeriksaanObservasiTransfusiDarahResourceFactory
{
    public function __invoke($services)
    {
        return new PemeriksaanObservasiTransfusiDarahResource();
    }
}
