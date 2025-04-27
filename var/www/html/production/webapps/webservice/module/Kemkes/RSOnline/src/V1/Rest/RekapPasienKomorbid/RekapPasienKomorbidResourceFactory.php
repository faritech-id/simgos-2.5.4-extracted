<?php
namespace Kemkes\RSOnline\V1\Rest\RekapPasienKomorbid;

class RekapPasienKomorbidResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RekapPasienKomorbidResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
