<?php
namespace MedicalRecord\V1\Rest\PenilaianBallanceCairanDetail;

class PenilaianBallanceCairanDetailResourceFactory
{
    public function __invoke($services)
    {
        return new PenilaianBallanceCairanDetailResource();
    }
}
