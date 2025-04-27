<?php
namespace Aplikasi\V1\Rest\GroupPenggunaAksesModule;

class GroupPenggunaAksesModuleResourceFactory
{
    public function __invoke($services)
    {
        $obj = new GroupPenggunaAksesModuleResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
