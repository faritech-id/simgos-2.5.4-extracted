<?php
namespace Inventory\V1\Rest\PenggolonganBarang;
use DBService\SystemArrayObject;
class PenggolonganBarangEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1 
		,'BARANG' => 1
		,'PENGGOLONGAN' => 1
		,'CHECKED' => 1 
    ];
}
