<?php
namespace MedicalRecord\V1\Rest\JenisIndikatorKeperawatan;

class JenisIndikatorKeperawatanResourceFactory
{
    public function __invoke($services)
    {
        return new JenisIndikatorKeperawatanResource();
    }
}
