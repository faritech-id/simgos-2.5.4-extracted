<?php
namespace MedicalRecord\V1\Rest\PenilaianBarthelIndexModifikasi;

class PenilaianBarthelIndexModifikasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenilaianBarthelIndexModifikasiResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
