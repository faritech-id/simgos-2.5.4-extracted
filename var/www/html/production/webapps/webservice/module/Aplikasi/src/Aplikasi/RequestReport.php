<?php
namespace Aplikasi;

use DBService\Crypto;
use Laminas\Authentication\Storage\Session as StorageSession;
use Aplikasi\db\request_report\Service as RequestServiceStorage;
use DBService\System;

use Ramsey\Uuid\Uuid;

class RequestReport
{
    private $crypto;
    private $config;
    private $key;
    private $rss;
    private $requestPrint;
    private $printdoc = null;
    
    public function __construct($config) {
        $this->config = $config['services']['SIMpelService'];
        
        $this->key = $this->config['plugins']['ReportService']['key'];
        $this->crypto = new Crypto();

        $this->storageSession = new StorageSession("RR", "RPT");
        $this->rss = new RequestServiceStorage();
        
        if(isset($this->config['plugins']['printdoc'])) $this->printdoc = $this->config['plugins']['printdoc'];
    }
    /**
     * Create a resource
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function create($data)
    {
        $uuid = Uuid::uuid4()->toString();

        $data = is_object($data) ? (array) $data : $data;
        $user = $data["USER_ID"];
        $printName = "";
        if(isset($data["PRINT_NAME"])) {
            $printName = $data["PRINT_NAME"];
            unset($data["PRINT_NAME"]);
        }
        $copies = 1;
        if(isset($data["COPIES"])) {
            $copies = $data["COPIES"];
            unset($data["COPIES"]);
        }
        if(isset($data["id"])) unset($data["id"]);
        $ds = isset($data["DOCUMENT_STORAGE"]) ? $data["DOCUMENT_STORAGE"] : null;
        
        if(!empty($data["REQUEST_REPORT_ID"])) {
            $dss = $this->rss->load([
                "ID" =>$data["REQUEST_REPORT_ID"],
                "STATUS" => 2
            ]);
            if(count($dss) > 0) {
                $dss = $dss[0];
                $url = $this->getUrl().$dss["KEY"];
                
                $result = [
                    'url' => $url
                ];
            }
        } else {
            $tgl = System::getSysDate($this->rss->getTable()->getAdapter(), false);
            $tgls = explode(" ", $tgl);
            $tgls = explode("-", $tgls[0]);
            $path = "reports/output/".$tgls[0]."/".$tgls[1]."/".$tgls[2]."/";
            $pathRequest = "reports/output/request/".$tgls[0]."/".$tgls[1]."/".$tgls[2]."/";
            $pathContent = "reports/output/content/".$tgls[0]."/".$tgls[1]."/".$tgls[2]."/";
            exec("sudo mkdir -p ".$path);
            exec("sudo mkdir -p ".$pathRequest);
            exec("sudo mkdir -p ".$pathContent);
            exec("sudo chmod 777 -Rf ".$path);
            exec("sudo chmod 777 -Rf ".$pathRequest);
            exec("sudo chmod 777 -Rf ".$pathContent);

            $notExists = false;
            $secret = "";
            while(!$notExists) {
                $secret = $this->crypto->generateKey($uuid);
                if(file_exists($pathRequest.$secret)) { // REQUEST_FOR_PRINT
                    exec("sudo chmod 775 -Rf ".$pathRequest.$secret);
                    unlink($pathRequest.$secret);
                } else $notExists = true;
            }

            $dss = false;
            $create = false;
            $sign = false;
            if($ds) {
                $sign = isset($data["DOCUMENT_STORAGE"]["SIGN"]) ? $data["DOCUMENT_STORAGE"]["SIGN"] == 1 : false;
                $ds = (array) $ds;
                if(!empty($ds["DOCUMENT_DIRECTORY_ID"]) && !empty($ds["REF_ID"])) {
                    $params = [
                        "DOCUMENT_DIRECTORY_ID" => $ds["DOCUMENT_DIRECTORY_ID"],
                        "REF_ID" => strval($ds["REF_ID"]),
                        "STATUS" => 1
                    ];
                    $dss = $this->rss->load($params);
                    if(count($dss) > 0) {
                        $dss = $dss[0];
                        if(!$sign) $sign = !empty($dss["TTD_OLEH"]);
                    } else {
                        $create = true;
                        $dss = $this->rss->simpanData([
                            "DOCUMENT_DIRECTORY_ID" => $ds["DOCUMENT_DIRECTORY_ID"],
                            "REF_ID" => $ds["REF_ID"],
                            "DIBUAT_TANGGAL" => new \Laminas\Db\Sql\Expression("NOW()"),
                            "DIBUAT_OLEH" => $user
                        ], true);
                        if(count($dss) > 0) $dss = $dss[0];
                    }
                }
            }
            
            $this->crypto->setKey($secret);
            $content = base64_encode(json_encode($data));
            $content = $this->crypto->encrypt($content);
            
            $this->requestPrint = false;
            if(isset($data["REQUEST_FOR_PRINT"])) {
                if($data["REQUEST_FOR_PRINT"]) {
                    $this->requestPrint = true;
                }
            }

            $url = $this->getUrl().$secret;
            $id = $this->config['instansi']['id'];
            if($this->printdoc) $id = $this->printdoc["id"];
            
            $result = [
                'url' => $url,
                "sign" => $sign
            ];

            if($this->requestPrint) {
                if(!$dss) file_put_contents($pathRequest.$secret, $content);
                $result = [
                    /* Id Instansi#PrinterName#PrinterOfCopies#DocumentType#DocumentURL#MethodRequest# */
                    'content'=>base64_encode($id.'#'.$printName.'#'.$copies.'#'.$data["EXT"].'#'.$url.'#GET#')
                ];
            }

            if(!$this->requestPrint && !$dss) {
                if(isset($data["REMOTE"])) file_put_contents($pathRequest.$secret, $content);
                else $this->storageSession->write($content);
            }
            if($dss) {
                $dss["KEY"] = $secret;
                $dss["REQUEST_DATA"] = $content;
                if(!$create) {
                    $dss["DIUBAH_TANGGAL"] = new \Laminas\Db\Sql\Expression("NOW()");
                    $dss["DIUBAH_OLEH"] = $user;
                }

                $this->rss->simpanData($dss, false, false);
            }
        }

        return $result;
    }
    
    private function getUrl() {
        $route = $this->config['plugins']['ReportService']['route'];
        $host = $this->config['plugins']['ReportService']['url'];
        $httpHost = explode(":", $_SERVER["HTTP_HOST"]);
        $remoteAddr = (substr($httpHost[0], 0, 1) == ':' || $httpHost[0] == "localhost") ? '127.0.0.1' : $httpHost[0];
        $client = explode(".", $remoteAddr);
        $port = count($httpHost) > 1 ? ":".$httpHost[1] : ($_SERVER["SERVER_PORT"] == "80" ? "" : ":".$_SERVER["SERVER_PORT"]);
        $client = (count($client) < 3 ? $route[$client[0].".".$client[1]] : $route[$client[0].".".$client[1].".".$client[2]]).($port == ":443" ? "" : $port);
        if($this->requestPrint) $client = $remoteAddr.($port == ":443" ? "" : $port);
        
        $host = str_replace('[HOST]', $client, $host);
        if($port == ":443") $host = str_replace('http', 'https', $host);
        
        return $host;
    }

    public function getRequestServiceStorage() {
        return $this->rss;
    }
}