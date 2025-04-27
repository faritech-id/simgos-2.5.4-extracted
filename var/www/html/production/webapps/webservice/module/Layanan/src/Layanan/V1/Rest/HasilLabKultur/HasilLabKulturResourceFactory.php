<?php
namespace Layanan\V1\Rest\HasilLabKultur;

class HasilLabKulturResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabKulturResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
