<?php
namespace MedicalRecord\V1\Rest\EdukasiPasienKeluarga;

class EdukasiPasienKeluargaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new EdukasiPasienKeluargaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
