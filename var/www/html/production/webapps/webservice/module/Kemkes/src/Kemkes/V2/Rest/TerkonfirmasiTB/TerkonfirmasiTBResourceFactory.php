<?php
namespace Kemkes\V2\Rest\TerkonfirmasiTB;

class TerkonfirmasiTBResourceFactory
{
    public function __invoke($services)
    {
        $kontb = new TerkonfirmasiTBResource($services);
    	$kontb->setServiceManager($services);
        return $kontb;
    }
}
