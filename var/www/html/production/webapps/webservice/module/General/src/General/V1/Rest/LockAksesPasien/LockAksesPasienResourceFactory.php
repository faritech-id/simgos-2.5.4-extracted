<?php
namespace General\V1\Rest\LockAksesPasien;

class LockAksesPasienResourceFactory
{
    public function __invoke($services)
    {
        return new LockAksesPasienResource();
    }
}
