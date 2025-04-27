<?php
namespace Pembayaran\V1\Rest\Transfer;
use DBService\SystemArrayObject;
class TransferEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1,
        'TAGIHAN' => 1,
        'BANK_ASAL' => 1,
        'REKENING' => 1,
        'NAMA_PENYETOR' => 1,
        'REF' => 1,
        'TANGGAL_TRANSFER' => 1,
        'TOTAL' => 1,
        'TANGGAL' => 1,
        'OLEH' => 1,
        'JENIS' => 1,
        'STATUS' => 1
    ];
}
