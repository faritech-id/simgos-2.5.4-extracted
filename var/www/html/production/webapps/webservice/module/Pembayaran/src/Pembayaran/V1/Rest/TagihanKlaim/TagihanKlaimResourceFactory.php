<?php
namespace Pembayaran\V1\Rest\TagihanKlaim;

class TagihanKlaimResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TagihanKlaimResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
