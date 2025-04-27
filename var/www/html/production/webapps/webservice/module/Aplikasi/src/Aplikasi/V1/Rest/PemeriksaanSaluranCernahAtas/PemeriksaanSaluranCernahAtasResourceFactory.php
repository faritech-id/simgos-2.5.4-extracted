<?php
namespace Aplikasi\V1\Rest\PemeriksaanSaluranCernahAtas;

class PemeriksaanSaluranCernahAtasResourceFactory
{
    public function __invoke($services)
    {
        return new PemeriksaanSaluranCernahAtasResource();
    }
}
