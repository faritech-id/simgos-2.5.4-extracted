<?php
namespace PenjaminRS\V1\Rest\CaraKeluar;

class CaraKeluarResourceFactory
{
    public function __invoke($services)
    {
        $obj = new CaraKeluarResource();
		$obj->setServiceManager($services);
		return $obj;
    }
}
