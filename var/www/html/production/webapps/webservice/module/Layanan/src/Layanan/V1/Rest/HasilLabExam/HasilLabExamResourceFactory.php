<?php
namespace Layanan\V1\Rest\HasilLabExam;

class HasilLabExamResourceFactory
{
    public function __invoke($services)
    {
        $obj = new HasilLabExamResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
