<?php
namespace Layanan\V1\Rest\StatusHasilPemeriksaan;

class StatusHasilPemeriksaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new StatusHasilPemeriksaanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
