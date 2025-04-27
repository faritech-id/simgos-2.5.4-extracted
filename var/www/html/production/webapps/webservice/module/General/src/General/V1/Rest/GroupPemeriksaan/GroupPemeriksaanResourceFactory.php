<?php
namespace General\V1\Rest\GroupPemeriksaan;

class GroupPemeriksaanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GroupPemeriksaanResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
