<?php
namespace General\V1\Rpc\PhotoPegawai;

class PhotoPegawaiControllerFactory
{
    public function __invoke($controllers)
    {
        return new PhotoPegawaiController($controllers);
    }
}
