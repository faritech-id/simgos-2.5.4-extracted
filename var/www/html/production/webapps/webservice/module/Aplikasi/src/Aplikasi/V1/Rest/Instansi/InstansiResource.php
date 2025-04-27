<?php
namespace Aplikasi\V1\Rest\Instansi;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;

class InstansiResource extends Resource
{
    protected $title = "Instansi";

	public function __construct(){
		parent::__construct();
		$this->service = new InstansiService();
	}

    protected function onBeforeAuthenticated($params = []) {
        $event = $params["event"];
        if($event->getName() == "fetchAll" || $event->getName() == "fetch") {
            $this->authType = self::AUTH_TYPE_NOT_SECURE; 
        }
    }

    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        return new ApiProblem(405, 'The POST method has not been defined');
    }

    /**
     * Delete a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function delete($id)
    {
        return new ApiProblem(405, 'The DELETE method has not been defined for individual resources');
    }

    /**
     * Delete a collection, or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function deleteList($data)
    {
        return new ApiProblem(405, 'The DELETE method has not been defined for collections');
    }

    /**
     * Fetch a resource
     *
     * @param  mixed $id
     * @return ApiProblem|mixed
     */
    public function fetch($id)
    {
        return new ApiProblem(405, 'The GET method has not been defined for individual resources');
    }

    /**
     * Fetch all or a subset of resources
     *
     * @param  array $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
		parent::fetchAll($params);		
        $data = null;        
        
        $total = $this->service->getRowCount($params);
		if($total > 0) $data = $this->service->load($params);
		
		return [
			"status" => $total > 0 ? 200 : 404,
			"success" => $total > 0 ? true : false,
			"total" => $total,
			"data" => $data,
			"detail" => $this->title.($total > 0 ? " ditemukan" : " tidak ditemukan")
        ];
    }

    /**
     * Patch (partial in-place update) a resource
     *
     * @param  mixed $id
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function patch($id, $data)
    {
        return new ApiProblem(405, 'The PATCH method has not been defined for individual resources');
    }

    /**
     * Replace a collection or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function replaceList($data)
    {
        return new ApiProblem(405, 'The PUT method has not been defined for collections');
    }

    /**
     * Update a resource
     *
     * @param  mixed $id
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function update($id, $data)
    {
        $data = is_array($data) ? $data : (array) $data; 
        $finds = $this->service->load(["ID" => $id]);
        $ppk = null;
        if(count($finds) > 0) {
            $ppk = $finds[0]["REFERENSI"]["PPK"];
            if(isset($data["DATA"])) {
                $dataTmp = $this->service->getFileContentFromPost($data["DATA"], ['image/jpeg', 'image/png'], "Salah upload gambar, format yang di izinkan jpg / png");
                if($dataTmp instanceof ApiProblem) {
                    $errors = $dataTmp->toArray();
                    return $errors;
                }

                if($data["JENIS"] == 1) {
                    file_put_contents("logs/".$ppk["ID"].".jpg", $dataTmp["content"]);
                    exec("sudo chmod 777 images/");
                    exec("sudo chmod 777 reports/images/");
                    exec("sudo yes | mv logs/".$ppk["ID"].".jpg images/");
                    exec("sudo yes | cp -Rf images/".$ppk["ID"].".jpg reports/images/");
                }
                if($data["JENIS"] == 2) {
                    file_put_contents("logs/".$ppk["ID"].".png", $dataTmp["content"]);
                    exec("sudo chmod 777 images/");
                    exec("sudo chmod 777 reports/images/");
                    exec("sudo yes | mv logs/".$ppk["ID"].".png images/");
                    exec("sudo yes | cp -Rf images/".$ppk["ID"].".png reports/images/");
                }

                if($data["JENIS"] == 3) {
                    file_put_contents("logs/".$ppk["ID"]."-background.jpg", $dataTmp["content"]);
                    exec("sudo chmod 777 images/");
                    exec("sudo yes | mv logs/".$ppk["ID"]."-background.jpg images/");
                }
                
                exec("sudo chmod 755 images/");
                exec("sudo chmod 755 reports/images/");

                return [
                    "status" => 200,
                    "success" => true,
                    "detail" => "Berhasil menyimpan gambar"
                ];
            }
        }

        $result = parent::update($id, $data);
        if($result["success"]) {
            if($ppk) {
                $instansi = $result["data"];
                $ppknew = $instansi["REFERENSI"]["PPK"];

                if($ppk["ID"] != $ppknew["ID"]) {
                    if($ppknew["JENIS"] == 1) exec("sudo bash ../scripts/migrations/mode_rs.sh");
                    else exec("sudo bash ../scripts/migrations/mode_klinik.sh");

                    $hash = sha1($ppknew["ID"]);
                    exec("sudo chmod 777 /var/www/html/production/webapps/application/SIMpel/classic.json");
                    exec("sudo chmod 777 /var/www/html/production/webapps/application/SIMpel/classic.jsonp");
                    $cmd01 = 'sudo sed -i -e \'s/\"hash\":\"[0-9a-f]*\"/"hash":"'.$hash.'"/\' /var/www/html/production/webapps/application/SIMpel/classic.json';
                    $cmd02 = 'sudo sed -i -e \'s/\"hash\":\"[0-9a-f]*\"/"hash":"'.$hash.'"/\' /var/www/html/production/webapps/application/SIMpel/classic.jsonp';
                    exec($cmd01);
                    exec($cmd02);
                    exec("sudo chmod 755 /var/www/html/production/webapps/application/SIMpel/classic.json");
                    exec("sudo chmod 755 /var/www/html/production/webapps/application/SIMpel/classic.jsonp");

                    exec("sudo chmod 777 config/autoload/local.php");
                    $cmd01 = 'sudo sed -i -e \'s/'.$ppk["KODE"].'/'.$ppknew["KODE"].'/\' config/autoload/local.php';
                    $cmd02 = 'sudo sed -i -e \'s/'.$ppk["BPJS"].'/'.$ppknew["BPJS"].'/\' config/autoload/local.php';
                    exec($cmd01);
                    exec($cmd02);
                    exec("sudo chmod 755 config/autoload/local.php");

                    exec("sudo chmod 777 -Rf reports");
                    $cmd01 = 'sudo find . -name "*.jrxml" -exec sh -c \'x={}; mv "$x" $(echo $x  | sed \'s/'.$ppk["KODE"].'/'.$ppknew["KODE"].'/g\')\' \;';
                    exec($cmd01);
                    exec("sudo chmod 755 -Rf reports");
                    exec("sudo chmod 777 -Rf reports/output");

                    exec("sudo rm -rf data/cache/*.php");
                }
            }
        }
        
		return $result;
    }
}
