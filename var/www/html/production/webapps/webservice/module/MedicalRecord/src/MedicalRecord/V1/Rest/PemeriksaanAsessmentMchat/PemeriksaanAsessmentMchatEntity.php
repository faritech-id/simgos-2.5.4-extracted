<?php
namespace MedicalRecord\V1\Rest\PemeriksaanAsessmentMchat;
use DBService\SystemArrayObject;

class PemeriksaanAsessmentMchatEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1     
		,"KUNJUNGAN"=>1     
		,"SUBJEKTIF"=>1     
		,"OBJEKTIF"=>1     
		,"M_CHAT_R"=>1     
		,"M_CHAT_FOLLOW_UP"=>1     
		,"INTERPERTASI"=>1     
		,"ANJURAN"=>1     
		,"DIBUAT_TANGGAL"=>1     
		,"OLEH"=>1
		,"STATUS"=>1  
	];
}
