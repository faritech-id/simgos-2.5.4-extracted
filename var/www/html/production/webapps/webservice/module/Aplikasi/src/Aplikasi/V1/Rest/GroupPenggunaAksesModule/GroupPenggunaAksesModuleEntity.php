<?php
namespace Aplikasi\V1\Rest\GroupPenggunaAksesModule;
use DBService\SystemArrayObject;

class GroupPenggunaAksesModuleEntity extends SystemArrayObject
{
	protected $fields = [
		'ID' => 1, 
		'GROUP_PENGGUNA' => [
            "DESCRIPTION" => "Id Grup Pengguna",
			"REQUIRED" => true
		], 
		'MODUL' => [
            "DESCRIPTION" => "Modul",
			"REQUIRED" => true
		], 
		'STATUS' => 1
	];
}
