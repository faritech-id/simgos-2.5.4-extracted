<?php
namespace DocumentStorage\V1\Rpc\Document;

class DocumentControllerFactory
{
    public function __invoke($controllers)
    {
        return new DocumentController($controllers);
    }
}
