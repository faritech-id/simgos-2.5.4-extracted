<?php
namespace Aplikasi\V1\Rpc\Images;

use DBService\RPCResource;
use Aplikasi\V1\Rest\Instansi\InstansiService;

class ImagesController extends RPCResource
{    
    private $instansi;
    
    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_NOT_SECURE;
        $this->allowIfLocking = true;
        $this->instansi = new InstansiService();
    }

    public function backgroundAction() {
        $instansi = $this->instansi->load([
            "start" => 0,
            "limit" => 1
        ]);
        $id = $instansi[0]["PPK"];        
        $tipe = "image/jpeg";
        $path = sprintf(realpath('.').'/images/%s-background.jpg', $id);
        if(file_exists($path)) {
            $image = file_get_contents($path);
        } else {
            $path = realpath('.').'/images/background.jpg';
            $image = file_get_contents($path);
        }
        
        return $this->downloadDocument($image, $tipe, "jpg", md5($id), false);
    }

    public function logoAction() {
        $query = (array) $this->getRequest()->getQuery();
        if(!isset($query["JENIS"])) {
            $this->response->setStatusCode(422);
            return [
                "status" => 422,
                "success" => false,
                "detail" => "Parameter JENIS harus di isi (1 = jpg, 2 = png)"
            ];
        }
        $instansi = $this->instansi->load([
            "start" => 0,
            "limit" => 1
        ]);
        $id = $instansi[0]["PPK"];        
        $tipe = $query["JENIS"] == 1 ? "image/jpeg" : "image/png";
        $ext = $query["JENIS"] == 1 ? "jpg" : "png";
        $path = sprintf(realpath('.').'/images/%s.%s', $id, $ext);
        if(file_exists($path)) {
            $image = file_get_contents($path);
        } else {
            $path = sprintf('../application/SIMpel/resources/images/1.%s', $ext);
            $image = file_get_contents($path);
        }
        
        return $this->downloadDocument($image, $tipe, $ext, md5($id), false);
    }

    public function getList() {
        $query = (array) $this->getRequest()->getQuery();
        $tipe = "image/png";
        $fn = isset($query["fn"]) ? $query["fn"] : "";
        $ext = isset($query["ext"]) ? $query["ext"] : "png";
        if($ext == "jpg") $tipe = "image/jpeg";
        $image = null;

        $path = sprintf(realpath('.').'/images/%s.%s', $fn, $ext);
        if(file_exists($path)) {
            $image = file_get_contents($path);
            return $this->downloadDocument($image, $tipe, $ext, $fn, false);
        }

        $this->response->setStatusCode(404);
        return [
            "status" => 404,
            "success" => false,
            "detail" => "Images file tidak di temukan"
        ];
    }
}
