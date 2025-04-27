<?php
namespace ReportService;

use Laminas\ApiTools\Provider\ApiToolsProviderInterface;

class Module implements ApiToolsProviderInterface
{
    public function getConfig()
    {
        return include __DIR__ . '/../../config/module.config.php';
    }

    public function getAutoloaderConfig()
    {
        return [
            'Laminas\ApiTools\Autoloader' => [
                'namespaces' => [
                    __NAMESPACE__ => __DIR__,
                ],
            ],
        ];
    }
	
	public function getServiceConfig() {
		return [
			'factories' => [
				'ReportService\ReportService' => function($sm) {
					$config = $sm->get('Config');
					$config = $config['services']['ReportService'];					
					return new \ReportService\ReportService($config);
				},
			]
		];
	}
}
