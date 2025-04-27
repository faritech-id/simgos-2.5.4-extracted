<?php
namespace BPJService;

use Laminas\ApiTools\Provider\ApiToolsProviderInterface;

class Module implements ApiToolsProviderInterface
{
    public function getConfig()
    {
        return include __DIR__ . '/../../config/module.config.php';
    }

    public function getAutoloaderConfig()
    {
        return array(
            'Laminas\ApiTools\Autoloader' => array(
                'namespaces' => array(
                    __NAMESPACE__ => __DIR__,
                ),
            ),
        );
    }
	
	public function getServiceConfig() {
		return array(
			'factories' => array(
				'BPJService\Service' => function($sm) {
					$config = $sm->get('Config');
					$config = $config['services']['BPJService'];
					$path = "\\BPJService\\";
					if($config["name"] != "") $path .= $config["name"]."\\";
					$path .= "v_".str_replace(".", "_", $config["version"]);
					$class = $path."\\Service";
					$instance = new $class($config);
					return $instance;
				},
			)
		);
	}
}
