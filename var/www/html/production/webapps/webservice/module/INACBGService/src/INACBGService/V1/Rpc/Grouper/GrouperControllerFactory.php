<?php
namespace INACBGService\V1\Rpc\Grouper;

class GrouperControllerFactory
{
    public function __invoke($controllers)
    {        
        return new GrouperController($controllers);
    }
}
