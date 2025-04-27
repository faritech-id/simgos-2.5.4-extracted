<?php
namespace Pembayaran\V1\Rest\Tagihan;

class TagihanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TagihanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
