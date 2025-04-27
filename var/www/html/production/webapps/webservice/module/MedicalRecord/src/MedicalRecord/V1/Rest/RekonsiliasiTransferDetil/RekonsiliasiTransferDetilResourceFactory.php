<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiTransferDetil;

class RekonsiliasiTransferDetilResourceFactory
{
    public function __invoke($services)
    {
        return new RekonsiliasiTransferDetilResource();
    }
}
