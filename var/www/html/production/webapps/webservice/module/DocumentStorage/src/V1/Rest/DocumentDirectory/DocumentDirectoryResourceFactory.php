<?php
namespace DocumentStorage\V1\Rest\DocumentDirectory;

class DocumentDirectoryResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DocumentDirectoryResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
