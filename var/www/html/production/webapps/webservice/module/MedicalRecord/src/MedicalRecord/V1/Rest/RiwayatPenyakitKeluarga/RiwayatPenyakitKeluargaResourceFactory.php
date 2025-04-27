<?php
namespace MedicalRecord\V1\Rest\RiwayatPenyakitKeluarga;

class RiwayatPenyakitKeluargaResourceFactory
{
    public function __invoke($services)
    {
		$obj = new RiwayatPenyakitKeluargaResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
