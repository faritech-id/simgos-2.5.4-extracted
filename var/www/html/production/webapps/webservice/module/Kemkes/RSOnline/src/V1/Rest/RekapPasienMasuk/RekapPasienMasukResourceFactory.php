<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienMasuk;

class RekapPasienMasukResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RekapPasienMasukResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
