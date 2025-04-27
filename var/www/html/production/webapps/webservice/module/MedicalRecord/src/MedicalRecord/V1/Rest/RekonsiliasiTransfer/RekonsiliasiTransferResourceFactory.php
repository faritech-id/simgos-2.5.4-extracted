<?php
namespace MedicalRecord\V1\Rest\RekonsiliasiTransfer;

class RekonsiliasiTransferResourceFactory
{
    public function __invoke($services)
    {
        return new RekonsiliasiTransferResource();
    }
}
