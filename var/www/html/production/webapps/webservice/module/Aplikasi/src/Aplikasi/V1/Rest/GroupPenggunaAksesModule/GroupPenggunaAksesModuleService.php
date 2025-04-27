<?php
namespace Aplikasi\V1\Rest\GroupPenggunaAksesModule;

use DBService\DatabaseService;
use Laminas\Db\Sql\TableIdentifier;
use Laminas\Db\Sql\Select;
use DBService\System;
use DBService\Service;

class GroupPenggunaAksesModuleService extends Service
{
    public function __construct() {
		$this->config["entityName"] = "Aplikasi\\V1\\Rest\\GroupPenggunaAksesModule\\GroupPenggunaAksesModuleEntity";
        $this->table = DatabaseService::get('SIMpel')->get(new TableIdentifier("group_pengguna_akses_module", "aplikasi"));
		$this->entity = new GroupPenggunaAksesModuleEntity();
		$this->limit = 5000;
    }
}
