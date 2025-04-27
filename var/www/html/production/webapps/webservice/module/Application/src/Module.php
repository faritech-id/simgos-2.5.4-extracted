<?php

declare(strict_types=1);

namespace Application;

use Laminas\Mvc\ModuleRouteListener;
use Laminas\Mvc\MvcEvent;
use Laminas\Uri\UriFactory;

class Module
{
    public function onBootstrap(MvcEvent $e)
    {
        $eventManager        = $e->getApplication()->getEventManager();
        $moduleRouteListener = new ModuleRouteListener();
        $moduleRouteListener->attach($eventManager);
        $eventManager->attach(MvcEvent::EVENT_FINISH, [$this, 'onFinish']);
		UriFactory::registerScheme('chrome-extension', 'Laminas\Uri\Uri');
    }

    /**
     * @return array<string,mixed>
     */
    public function getConfig()
    {
        return include __DIR__ . '/../config/module.config.php';
    }

    public function onFinish(MvcEvent $e) {
        $response = $e->getResponse();
        $headers = $response->getHeaders();
        $contentType = $headers->get('Content-Type');
        if($contentType) {
            if (strpos($contentType->getFieldValue(), 'application/json') !== false) {
                $content = json_decode($response->getContent());
                if(isset($content->status)) {
                    if($content->status == 404) {
                        if(isset($content->reason)) unset($content->reason);
                        if(isset($content->message)) unset($content->message);
                        if(isset($content->display_exceptions)) unset($content->display_exceptions);
                        if(isset($content->controller)) unset($content->controller);
                        if(isset($content->controller_class)) unset($content->controller_class);                        
                        $content = json_encode($content);
                        $response->setContent($content);
                    }
                }
            }
        }
    }
}
