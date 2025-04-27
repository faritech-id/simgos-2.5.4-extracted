<?php
namespace General\V1\Rest\MappingGroupPemeriksaan;

class MappingGroupPemeriksaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new MappingGroupPemeriksaanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
