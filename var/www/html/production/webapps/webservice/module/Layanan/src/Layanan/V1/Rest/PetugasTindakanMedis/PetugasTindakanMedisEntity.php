<?php
namespace Layanan\V1\Rest\PetugasTindakanMedis;
use DBService\SystemArrayObject;

class PetugasTindakanMedisEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1 
		, 'TINDAKAN_MEDIS'=>1
		, 'JENIS'=>1
		, 'MEDIS'=>1	    
		, 'KE'=>1
		, 'STATUS'=>1	   
	];
}
