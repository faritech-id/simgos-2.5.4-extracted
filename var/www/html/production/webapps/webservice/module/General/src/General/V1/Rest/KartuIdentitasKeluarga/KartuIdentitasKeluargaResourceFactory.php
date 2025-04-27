<?php
namespace General\V1\Rest\KartuIdentitasKeluarga;

class KartuIdentitasKeluargaResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KartuIdentitasKeluargaResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
