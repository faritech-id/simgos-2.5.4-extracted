<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienNonKomorbid;

class RekapPasienNonKomorbidResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RekapPasienNonKomorbidResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
