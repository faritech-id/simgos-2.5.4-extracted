<?php
namespace DocumentStorage;

use \Exception;

/**
 * This source code location https://www.php.net/manual/en/function.ssh2-sftp.php
 */

class SFTPConnection
{
    private $connection;
    private $sftp;

    public function __construct($host, $port=22)
    {
        $this->connection = @ssh2_connect($host, $port);
        if (! $this->connection)
            throw new Exception("Could not connect to $host on port $port.");
    }

    public function login($username, $password)
    {
        if (! @ssh2_auth_password($this->connection, $username, $password))
            throw new Exception("Could not authenticate with username $username " . "and password $password.");
        $this->sftp = @ssh2_sftp($this->connection);
        if (! $this->sftp)
            throw new Exception("Could not initialize SFTP subsystem.");
    }

    public function createDirectory($folder) {
        $result = @ssh2_sftp_mkdir($this->sftp, $folder);
        return $result;
    }

    public function uploadFile($local_file, $remote_file)
    {
        $sftp = $this->sftp;
        $stream = @fopen("ssh2.sftp://$sftp$remote_file", 'w');
        if (! $stream)
            throw new Exception("Could not open file: $remote_file");
        $data_to_send = @file_get_contents($local_file);
        if ($data_to_send === false)
            throw new Exception("Could not open local file: $local_file.");
        if (@fwrite($stream, $data_to_send) === false)
            throw new Exception("Could not send data from file: $local_file.");
        @fclose($stream);
        return true;
    }

    public function uploadStreamData($data, $remote_file)
    {
        $sftp = $this->sftp;
        $stream = @fopen("ssh2.sftp://$sftp$remote_file", 'w');
        if (! $stream)
            throw new Exception("Could not open file: $remote_file");
        if (@fwrite($stream, $data) === false)
            throw new Exception("Could not send data from file: $local_file.");
        @fclose($stream);
        return true;
    }
   
    public function downloadFile($remote_file, $local_file)
    {
        $sftp = $this->sftp;
        $stream = @fopen("ssh2.sftp://$sftp$remote_file", 'r');
        if (! $stream)
            throw new Exception("Could not open file: $remote_file");
        //$size = @filesize("ssh2.sftp://$sftp$remote_file");
        //$contents = @fread($stream, $size);
        $contents = @stream_get_contents($stream);   
        file_put_contents ($local_file, $contents);
        @fclose($stream);
        return true;
    }

    public function downloadStreamData($remote_file)
    {
        $sftp = $this->sftp;
        $stream = @fopen("ssh2.sftp://$sftp$remote_file", 'r');
        if (! $stream)
            throw new Exception("Could not open file: $remote_file");
        $contents = @stream_get_contents($stream);          
        @fclose($stream);
        return $contents;
    }

    public function disconnect() {
        if($this->connection) ssh2_disconnect($this->connection);
    }
}