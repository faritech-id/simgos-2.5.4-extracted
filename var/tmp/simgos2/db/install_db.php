#!/usr/bin/env php

<?php

class Command {
    private $conn;
    private $config;
    private $targetDir;
    private $myConfigFile;
    private $myCnfDir;
    private $isLinux;

    function __construct() {
        $this->config = $this->getConfig();
        //$this->initConnection();

        $this->targetDir = realpath($this->config["target_directory"]);
        $this->myCnfDir = realpath($this->config["my_cnf_location"]);
        $this->isLinux = $this->myCnfDir == "." ? false : true;
        $this->createMyConfig();
        if(is_dir($this->targetDir."/new")) $this->targetDir = $this->targetDir."/new";
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

    public function run() {  
        //$conn = $this->conn;       
        $conf = $this->config;
        $targetDir = $this->targetDir;
        $dirs = scandir($targetDir);
        foreach($dirs as $d) {
            if(!isset($conf["except"]["directory"][$d])) {
                //if($d == "aplikasi") {
                echo "========================================\r\n";
                printf("Create DB: %s\r\n", $d);
                echo "========================================";
                $this->executeMysql($targetDir."/".$d."/create_db.sql");

                # create tables
                $this->doTable($d);

                # import data
                $this->doData($d);

                # create routines
                $this->doRoutine($d);

                # create triggers
                $this->doTrigger($d);

                # create events
                $this->doEvent($d);

                echo "\r\n";
                //}
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
        //$db = $conf["db"];        
        /*$conn = $this->conn;        
        $content = file_get_contents($filename);        
        $conn->query($content);
        echo $conn->error;*/

        /*
        $cmd = $conf["mysql_location"]
            ." -h ".$db["host"]
            ." -P ".$db["port"]
            ." -u ".$db["user"]
            .($dbname !== "" ? " -D ".$dbname : "")
            ." -p".$db["password"]            
            ." < ".$filename;
        */
        $cmd = $conf["mysql_location"]
            ." --defaults-extra-file=".($this->myConfigFile)
            .($dbname !== "" ? " -D ".$dbname : "")            
            ." < ".$filename;
        //printf("import %s\n", $cmd);
        echo shell_exec($cmd)."\n";
    }

    private function doTable($db) {
        $conf = $this->config;       
        $targetDir = $this->targetDir;
        $targetDir .= "/".$db."/tables";
        if(!is_dir($targetDir)) return;
        $dirs = scandir($targetDir);
        foreach($dirs as $f) {  
            if(!isset($conf["except"]["directory"][$f])) {
                if(is_file($targetDir."/".$f)) {
                    printf("Create Table: %s", $f);
                    $this->executeMysql($targetDir."/".$f, $db);
                }
            }
        }
    }

    private function doData($db) {
        $conf = $this->config;
        $targetDir = $this->targetDir;
        $targetDir .= "/".$db."/data";
        if(!is_dir($targetDir)) return;
        $dirs = scandir($targetDir);        
        foreach($dirs as $f) {  
            if(!isset($conf["except"]["directory"][$f])) {
                if(is_file($targetDir."/".$f)) {
                    printf("Import data: %s", $f);
                    $this->executeMysql($targetDir."/".$f, $db);
                }
            }
        }     
    }

    private function doRoutine($db) {
        $conf = $this->config;
        $targetDir = $this->targetDir;
        $targetDir .= "/".$db."/routines";
        if(!is_dir($targetDir)) return;
        $dirs = scandir($targetDir);        
        foreach($dirs as $f) {  
            if(!isset($conf["except"]["directory"][$f])) {
                if(is_file($targetDir."/".$f)) {
                    printf("Create Routine: %s", $f);
                    $this->executeMysql($targetDir."/".$f, $db);
                }
            }
        }     
    }

    private function doTrigger($db) {
        $conf = $this->config;
        $targetDir = $this->targetDir;
        $targetDir .= "/".$db."/triggers";
        if(!is_dir($targetDir)) return;
        $dirs = scandir($targetDir);
        foreach($dirs as $f) {  
            if(!isset($conf["except"]["directory"][$f])) {
                if(is_file($targetDir."/".$f)) {
                    printf("Create Trigger: %s", $f);
                    $this->executeMysql($targetDir."/".$f, $db);
                }
            }
        }     
    }

    private function doEvent($db) {
        $conf = $this->config;
        $targetDir = $this->targetDir;
        $targetDir .= "/".$db."/events";
        if(!is_dir($targetDir)) return;
        $dirs = scandir($targetDir);
        foreach($dirs as $f) {  
            if(!isset($conf["except"]["directory"][$f])) {
                if(is_file($targetDir."/".$f)) {
                    printf("Create Event: %s", $f);
                    $this->executeMysql($targetDir."/".$f, $db);
                }
            }
        }
    }
}

$cmd = new Command();
$cmd->run();
?>