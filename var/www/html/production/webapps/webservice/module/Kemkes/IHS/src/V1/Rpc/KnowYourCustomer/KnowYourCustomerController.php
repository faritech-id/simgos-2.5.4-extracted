<?php
namespace Kemkes\IHS\V1\Rpc\KnowYourCustomer;

use Kemkes\IHS\RPCResource;
use Kemkes\IHS\V1\Rpc\Location\Service;
use Kemkes\IHS\KYC;
use General\V1\Rest\Pegawai\PegawaiService;

class KnowYourCustomerController extends RPCResource
{
    private $kycservice;
    private $pegawaiservice;
    public function __construct($controller)
    {
        parent::__construct($controller);
        $config = $controller->get('Config');
        $config = $config['services']['KemkesService'];
        $config = $config['IHS'];
        $kyc = isset($config['kyc']) ? $config['kyc'] : false ;
        
        $this->kycservice = new KYC($kyc); 
        $this->pegawaiservice = new PegawaiService();
    }

    public function urlAction()
    {
        $respon = [
			"status" => 404,
			"success" => false,
			"total" => 0,
			"data" => [],
			"detail" => "Gagal memuat url"
        ];
        $user = $this->auth->getIdentity();
        $auth_result = $this->token;
        
        if(!empty($user->NIP)){
            $agent_name = '';
            $agent_nik ='';

            $pegawai = $this->pegawaiservice->load(["NIP" => $user->NIP]);
            if(count($pegawai) > 0) {
                $recpeg = $pegawai[0];
                $agent_name = $recpeg["NAMA"];
                if(isset($recpeg["KARTU_IDENTITAS"])){
                    foreach($recpeg["KARTU_IDENTITAS"] as $ki){
                        if($ki["JENIS"] == 1) $agent_nik = $ki["NOMOR"];
                    }
                    if(!empty($agent_nik)){
                        $return = $this->kycservice->generateUrl($agent_name, $agent_nik , $auth_result);
                        $data = json_decode($return);
                        $metadata = $data->metadata;
                        if($metadata->code == 200)
                        if(isset($data->data)) {
                            $data = $data->data;
                            $respon["status"] = 200;
                            $respon["success"] = true;
                            $respon["total"] = 1;
                            $respon["detail"] = "Berhasil memuat url";
                            $respon["data"][0] = [
                                "url" =>  $data->url,
                                "agent_name" => $data->agent_name,
                                "agent_nik" => $data->agent_nik,
                                "token" => $data->token,
                            ];
                        }
                    } else $respon["detail"] = "User anda tidak memiliki nomor KTP (NIK)";                   
                } else $respon["detail"] = "User anda tidak memiliki kartu identitas";
            } else $respon["detail"] = "user anda tidak ditemukan di daftar pegawai";
        }        
        return $respon;
    }
}
