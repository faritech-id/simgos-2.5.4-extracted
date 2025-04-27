<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienKeluar;

class RekapPasienKeluarResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RekapPasienKeluarResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
