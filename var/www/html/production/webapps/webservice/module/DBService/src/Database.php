<?php
namespace DBService;

use Laminas\Db\Adapter\AdapterInterface;
use Laminas\Db\TableGateway\TableGateway;

class Database
{	
	private $adapter;
	
	public function __construct(AdapterInterface $adapter) {
        $this->adapter = $adapter;
    }
	
    public function get($name = '') {
        return new TableGateway($name, $this->adapter);
    }
	
	public function getAdapter() {
		return $this->adapter;
	}
}
