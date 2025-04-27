<?php

class Command {
    private $conn;
    private $config;
    private $targetDir;
    private $myConfigFile;
    private $myCnfDir;
    private $isLinux;

    private $vers;

    function __construct($args) {
        $this->config = $this->getConfig();
        //$this->initConnection();

        $this->targetDir = realpath($this->config["target_directory"]);
        $this->myCnfDir = realpath($this->config["my_cnf_location"]);
        $this->isLinux = $this->myCnfDir == "." ? false : true;
        $this->createMyConfig();        

        if(count($args) > 2) {            
            if($args[1] == "-p") {
                if(count($args) < 4) $this->usage();            
                $this->vers = explode("-", $args[3]);            
                if(count($this->vers) < 2) $this->usage();
                if(is_dir($this->targetDir."/plugins/".$args[2])) $this->targetDir = $this->targetDir."/plugins/".$args[2];
                else {
                    echo "Lokasi patch db plugin ".$args[2]." tdk ditemukan";
                    exit;
                }
            } else {
                $this->usage();
            }
        } else {
            if(count($args) < 2) $this->usage();
            if($args[1] == "-p") $this->usage();             
            $this->vers = explode("-", $args[1]);                        
            if(count($this->vers) < 2) $this->usage();
            if(is_dir($this->targetDir."/patchs")) $this->targetDir = $this->targetDir."/patchs";
        }
    }

    private function getConfig() {
        return include __DIR__ . '/config.php';
    }

    private function initConnection() {
        $conf = $this->config;
        $this->conn = new mysqli($conf["db"]["host"], $conf["db"]["user"], $conf["db"]["password"], $conf["db"]["schema"], $conf["db"]["port"]);

        if($this->conn->connect_errno) {
            printf("Connect failed: %s\n", $mysqli->connect_error);
            exit();
        }
    }

    private function createMyConfig() {
        $db = $this->config["db"];
        $conf = "[client]\r\n";
        $conf .= "host=".$db["host"]."\r\n";
        $conf .= "port=".$db["port"]."\r\n";
        $conf .= "user=".$db["user"]."\r\n";        
        $conf .= "password=".$db["password"]."\r\n";

        $this->myConfigFile = $this->myCnfDir."/my.cnf";
        file_put_contents($this->myConfigFile, $conf);
    }

    private function usage() {
        $cmd = "Usage: \r\n";
        $cmd .= "   php patch_db.php last_version\r\n";
        $cmd .= "   Example: php patch_db.php 2.0-190929\r\n";
        $cmd .= "Usage plugins: \r\n";
        $cmd .= "   php patch_db.php -p plugins_name last_version\r\n";
        $cmd .= "   Example: php patch_db.php -p ppi 1.0.0-20061700\r\n";
        printf($cmd);

        if($this->isLinux) {
            echo shell_exec("sudo rm -rf ".$this->myConfigFile)."\n";
        } else {
            unlink($this->myConfigFile);
        }
        exit;
    }

    public function run() {        
        //$conn = $this->conn;       
        $conf = $this->config;
        $vers = $this->vers;
        $targetDir = $this->targetDir;
        //$targetDir .= "/".$vers[0];
        $dirs = scandir($targetDir);        

        foreach($dirs as $d) {         
            if(!isset($conf["except"]["directory"][$d])) {   
                if(is_dir($targetDir."/".$d)) {
                    if($d >= $vers[0]) {
                        echo "========================================\r\n";
                        printf("Patch Version: %s\r\n", $d);
                        echo "========================================\r\n";                                
                        $this->doVersionPatchs($d);                           
                        echo "\r\n";
                    }
                }
            }           
        }

        //$conn->close();
        if($this->isLinux) {
            echo shell_exec("sudo rm -rf ".$this->myConfigFile)."\n";
        } else {
            unlink($this->myConfigFile);
        }
    }
    
    private function executeMysql($filename, $dbname = "") {
        $conf = $this->config;
        $cmd = $conf["mysql_location"]
            ." --defaults-extra-file=".($this->myConfigFile)
            .($dbname !== "" ? " -D ".$dbname : "")            
            ." < ".$filename;
        //printf("import %s\n", $cmd);
        echo shell_exec($cmd)."\n";
    }

    private function doVersionPatchs($version) {
        //$conn = $this->conn;       
        $conf = $this->config;
        $vers = $this->vers;
        $targetDir = $this->targetDir;
        $targetDir .= "/".$version;
        $dirs = scandir($targetDir);

        foreach($dirs as $d) {         
            if(!isset($conf["except"]["directory"][$d])) {   
                if(is_dir($targetDir."/".$d)) {
                    if($d > $vers[1]) {
                        printf("Build: %s\r\n", $d);                  
                        $this->doPatchFile($version, $d);                           
                        echo "\r\n";
                    }
                }
            }           
        }
    }

    private function doPatchFile($version, $build) {
        $conf = $this->config;
        $targetDir = $this->targetDir;
        $targetDir .= "/".$version."/".$build;
        $dirs = scandir($targetDir);
        foreach($dirs as $f) {  
            if(!isset($conf["except"]["directory"][$f])) {
                $files = explode(".", $f);
                if(count($files) > 0) {
                    if(is_file($targetDir."/".$f) && $files[1] == "sql") {
                        printf("    File: %s", $f);
                        $this->executeMysql($targetDir."/".$f);
                    }
                }
            }
        }    
    }
}

$cmd = new Command($argv);
$cmd->run();
?>