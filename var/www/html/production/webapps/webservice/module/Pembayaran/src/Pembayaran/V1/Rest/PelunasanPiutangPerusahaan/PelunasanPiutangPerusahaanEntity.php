<?php
namespace Pembayaran\V1\Rest\PelunasanPiutangPerusahaan;
use DBService\SystemArrayObject;
class PelunasanPiutangPerusahaanEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1,
        'TAGIHAN_PIUTANG' => 1,
        'PENJAMIN' => 1,
        'TOTAL_PIUTANG' => 1, 
        'TOTAL_BAYAR' => 1,
        'TANGGAL' => 1,
        'OLEH' => 1,
        'STATUS' => 1
    ];
}
