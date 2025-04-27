<?php
namespace Pembayaran\V1\Rest\PelunasanPiutangPasien;
use DBService\SystemArrayObject;

class PelunasanPiutangPasienEntity extends SystemArrayObject
{
    protected $fields = [
        'ID' => 1,
        'TAGIHAN_PIUTANG' => 1,
        'ANGSURAN_KE' => 1,
        'JUMLAH_ANGSURAN_DIBAYAR' => 1,
        'TOTAL_BAYAR' => 1,
        'TANGGAL' => 1,
        'JENIS_PEMBAYARAN' => 1,
        'OLEH' => 1,
        'STATUS' => 1
    ];
}
