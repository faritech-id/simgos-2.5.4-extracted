<?php
namespace Aplikasi\V1\Rpc\Images;

class ImagesControllerFactory
{
    public function __invoke($controllers)
    {
        return new ImagesController($controllers);
    }
}
