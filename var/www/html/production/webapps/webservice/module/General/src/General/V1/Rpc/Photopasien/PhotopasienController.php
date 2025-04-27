<?php
namespace General\V1\Rpc\Photopasien;

use DBService\RPCResource;
use Laminas\ApiTools\ApiProblem\ApiProblem;

class PhotopasienController extends RPCResource
{
    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_LOGIN;
        $this->service = new Service();
    }
    
    /**
     * Create a new resource
     *
     * @param  mixed $data
     * @return mixed
     */
    public function create($data) {
        $result = array(
            "status" => 422,
            "success" => false,
            "detail" => "Gagal menyimpan Photo Pasien"
        );
        
        $data = is_array($data) ? $data : (array) $data; 
        $norm = $data["NORM"];
        $finds = $this->service->load(["NORM" => $norm]);
        
        $dataTmp = $this->service->getFileContentFromPost($data["DATA"], ['image/jpeg', 'image/png'], "Salah upload Photo Pasien, format yang di izinkan jpg / png");
        if($dataTmp instanceof ApiProblem) {
            $errors = $dataTmp->toArray();
            $this->response->setStatusCode($errors["status"]);
            return $errors;
        }
        
        $data["DATA"] = $dataTmp["content"];
        $data["TIPE"] = $dataTmp["tipe"];
        $success = $this->service->simpanData($data, count($finds) == 0, false);
        if($success) {
            $result["status"] = 200;
            $result["success"] = true;
            $result["detail"] = "Berhasil menyimpan Photo Pasien";
        }
        
        $this->response->setStatusCode($result["status"]);
        unset($data["DATA"]);
        return $result;
    }
    
    /**
     * Return list of resources
     *
     * @return mixed
     */
    public function getList()
    {
        $queries = (array) $this->request->getQuery();
        
        $norm = $queries['NORM'] ? $queries['NORM'] : 0;
        $jk = $queries['JENIS_KELAMIN'] ? ($queries['JENIS_KELAMIN'] == 1 ? 'male' : 'female') : 'male';
        $tipe = 'image/jpg';
        $ext = "jpg";
        
        $finds = $this->service->load(["NORM" => $norm]);
        if(count($finds) > 0) {
            $photo = $finds[0]["DATA"];
            $tipe = $finds[0]["TIPE"];
            $ext = substr($tipe, strlen($tipe) - 3);
        } else {
            $path = realpath('.').'/photos/'.$norm.'.jpg';
            if(file_exists($path)) {
                $photo = file_get_contents($path);
            } else {
                $path = realpath('.').'/photos/'.$jk.'.jpg';
                $photo = file_get_contents($path);
            }
        }
        
        return $this->downloadDocument($photo, $tipe, "jpg", md5($norm), false);
    }
}