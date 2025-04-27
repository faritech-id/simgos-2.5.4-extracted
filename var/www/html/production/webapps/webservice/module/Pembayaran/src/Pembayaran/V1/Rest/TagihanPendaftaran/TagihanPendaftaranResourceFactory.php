<?php
namespace Pembayaran\V1\Rest\TagihanPendaftaran;

class TagihanPendaftaranResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TagihanPendaftaranResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
