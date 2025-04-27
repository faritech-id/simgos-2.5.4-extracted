<?php
namespace Kemkes\IHS\V1\Rpc\DiagnosticReport;

class DiagnosticReportControllerFactory
{
    public function __invoke($controllers)
    {
        return new DiagnosticReportController($controllers);
    }
}
