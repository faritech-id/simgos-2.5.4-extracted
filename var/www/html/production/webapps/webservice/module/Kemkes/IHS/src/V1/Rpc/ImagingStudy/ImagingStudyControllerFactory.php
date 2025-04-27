<?php
namespace Kemkes\IHS\V1\Rpc\ImagingStudy;

class ImagingStudyControllerFactory
{
    public function __invoke($controllers)
    {
        return new ImagingStudyController($controllers);
    }
}
