<?php
namespace Aplikasi\V1\Rpc\Tentang;

use DBService\RPCResource;

class TentangController extends RPCResource
{
    public function __construct($controller) {
        $this->authType = self::AUTH_TYPE_NOT_SECURE;        
    }

    public function changelogAction() {
        $path = str_replace("webservice", "", realpath("."));
        $content = file_get_contents($path."CHANGELOG.md");

        $content = str_replace("# CHANGELOG", "", $content);
        $versions = explode("## ", $content);
        $realContent = "<div style='background: rgb(40, 44, 52); color: #abb2bf; font-family: sans-serif; font-size: 16px;'>";
        foreach($versions as $ver) {
            $changes = explode("\n", $ver);
            $i = 0;
            $cnt = count($changes);
            foreach($changes as &$cha) {                                
                if(trim($cha) == "" || trim($cha) == "\n") {
                    $cnt--;                        
                    if($i == $cnt) $realContent .= "</ul>";
                    continue;
                }
                if($i == 0) $cha = "<div><span style='color: #61afef; font-weight: bold;'>".$cha."</span></div>";
                $ul = "";
                $ulEnd = "";
                if($i == 1) $ul = "<ul>";
                if($i == ($cnt - 1)) $ulEnd = "</ul>";
                if($i > 0) $cha = $ul."<li>".str_replace("- ", "", $cha)."</li>".$ulEnd;
                $i++;
            }        
            $realContent .= implode($changes);
        }

        $realContent .= "</div>";

        $response = $this->downloadDocument($realContent, "text/html", "html", "changelog", false);

        return $response;
    }

    public function kontakAction() {
        $content = "";
        $content .= '<span style="font-size: 21px">'.
            '<b>Syarat mendapatkan SIMGOS:</b><br>'.
            '    1. Fasyankes sudah mempunyai infrastruktur IT (Jaringan, Komputer dan Server)<br>'.
            '    2. Fasyankes mempunyai minimal 1 orang SDM IT (programmer)<br><br>'.
            '    <b>Alur mendapatkan SIMGOS:</b><br>'.
            '    1. Mengajukan permohonan penggunaan SIMGOS kepada Sesditjen Pelayanan Kesehatan<br>'.
            '    2. Pengisian<i> self assessment </i>kesiapan infrastruktur dan SDM Fasyankes<br>'.
            '    3. Pemberian surat izin penggunaan oleh Sesditjen Pelayanan Kesehatan<br>'.
            '    4. Penyerahan dan training SIMGOS kepada Fasyankes<br>'.
            '    5. Perawatan dan pengembangan SIMGOS dilakukan oleh Fasyankes masing-masing (internal Fasyankes atau pihak ketiga)<br><br>'.
            
            '   <b>Informasi lebih lanjut dapat menghubungi SubbagInformasi dan Evaluasi PI Yankes<br>'.
            '    <span class="fa fa-email">Email: infomonev.yankes@gmail.com</span><br>'.
            '    Telepon: 0215261813 (fax), 021 5201590 ext 1303<b>'.
            '</span>';

        $response = $this->downloadDocument($content, "text/html", "html", "kontak", false);

        return $response;
    }

    public function contributorAction() {
        $contributors = [
            "owner" => [
                "name" => "Kementerian Kesehatan Republik Indonesia",
                "teams" => [
                    [ "id" => 1, "name" => "Haidar Istiqlal, S.Kom", "role" => "" ]
                ]
            ],
            "author" => [
                "name" => "SIMpel Development",
                "teams" => [
                    [ "id" => 1, "name" => "Poentoro, S.Si., M.Kom", "role" => "Project Manager"],
                    [ "id" => 2, "name" => "Hariansyah Erwin Noer, S.Kom", "role" => "Development Team" ],
                    [ "id" => 3, "name" => "Asrang, S.Kom", "role" => "Development Team - System Analyst" ],
                    [ "id" => 4, "name" => "Munawir, S.Kom", "role" => "Development Team - System Analyst" ],
                    [ "id" => 5, "name" => "Zaldi, A.Md.Kom", "role" => "Development Team - System Analyst" ],
                    [ "id" => 6, "name" => "Budirman, A.Md.Kom", "role" => "Development Team - Web Developer" ],
                    [ "id" => 7, "name" => "Asmadi, A.Md.Kom", "role" => "Development Team - Web Developer" ],
                    [ "id" => 8, "name" => "Muhammad Rizal Ibrahim, A.Md.Kom", "role" => "Development Team - Web Developer" ],
                    [ "id" => 9, "name" => "Achmad Febriansyah", "role" => "Development Team - Mobile Developer" ],
                    [ "id" => 10, "name" => "Nur Alamsyah, SE", "role" => "Development Team - Data dan Reporting" ],
                    [ "id" => 11, "name" => "Muchtamar, S.Sos", "role" => "Bussiness Requirement Team" ],
                    [ "id" => 12, "name" => "Aris Munandar Arsyad, SKM", "role" => "Bussiness Requirement Team" ],
                    [ "id" => 13, "name" => "Faizal, S.Sos", "role" => "Bussiness Requirement Team" ],				
                    [ "id" => 14, "name" => "Saddam Hussain, S.Pd", "role" => "Documentation Team" ],
                    [ "id" => 15, "name" => "Achmad Zarkasyi, A.Md.Kom", "role" => "Quality Assurance Team" ],				
                    [ "id" => 16, "name" => "Putry Dwi Sulistyarini, S.Si,Apt", "role" => "Finance" ],				
                    [ "id" => 17, "name" => "Nur Alam", "role" => "Support Team" ],
                    [ "id" => 18, "name" => "Muhammad Abdi, S.Kom", "role" => "Support Team" ],
                    [ "id" => 19, "name" => "Amar Muhaimin, S.Kom", "role" => "Implementator Team" ],
                    [ "id" => 20, "name" => "Moh. Fauzi, S.IP", "role" => "Implementator Team" ],
                    [ "id" => 21, "name" => "Eko Fitrianto, ST", "role" => "Implementator Team" ],
                    [ "id" => 22, "name" => "Nurul Baeti, S.Kom", "role" => "Implementator Team" ],
                    [ "id" => 23, "name" => "Muchnady, A.Md", "role" => "Implementator Team" ],
                    [ "id" => 24, "name" => "Permadi Ridwan, S.Kom", "role" => "Implementator Team" ],
                    [ "id" => 25, "name" => "Ardhya Adisurya, S.Kom", "role" => "Implementator Team" ],
                    [ "id" => 26, "name" => "Moh. Zulfahri Saputro, S.Kom", "role" => "Implementator Team" ],
                    [ "id" => 27, "name" => "Azwar Rasyid", "role" => "Implementator Team" ],
                    [ "id" => 28, "name" => "Akbar", "role" => "Implementator Team" ],
                ]
            ],
            "contributors" => [
                [
                    "title" => "Logo Design",
                    "teams" => [
                        [ "id" => 1, "name" => "Fadri Apriliyandi", "role" => "Freelancer UI/UX" ]
                    ]
                ],
                [
                    "title" => "SIMpel Font",
                    "teams" => [
                        [ "id" => 1, "name" => "Andi Muhammad Ridwan Ahmad, A.Md.Kom" ]
                    ]
                ],
                [
                    "title" => "Development",
                    "teams" => [
                        [ "id" => 1, "name" => "Tutu Gondewa, SE., M. Kom", "role" => "IT RSUD. dr. Slamet Garut" ]
                    ]
                ],
                [
                    "title" => "RME",
                    "teams" => [
                        [ "id" => 1, "name" => "Ni Nengah Duwiyani,S.Kep, Ners", "role" => "RME" ],
                        [ "id" => 2, "name" => "Rahmadaini, S.Kep, Ners, Sp.KV", "role" => "RME" ],
                        [ "id" => 3, "name" => "dr. Az Hafid Nashar, Sp.JP", "role" => "RME" ],
                        [ "id" => 4, "name" => "dr. Muh. Asrul Apris, Sp.JP", "role" => "RME" ],
                        [ "id" => 5, "name" => "dr. Zulvinah Santy Arsjad, M.Kes", "role" => "RME" ],
                        [ "id" => 6, "name" => "Aras Rasyid, A.Md.Pk", "role" => "RME" ],
                        [ "id" => 7, "name" => "dr. Sulmiati, Sp.BA", "role" => "RME" ]
                    ]
                ]
            ]
        ];
        
        $content = "<div style='background: rgb(40, 44, 52); color: #abb2bf; text-align: center; font-family: sans-serif; font-size: 16px;'>"
            ."<br/><br/>"
            ."<div>Owner</div>"
            ."<div><span style='color: #d7ba7d; font-weight: bold; font-size: 17px'>".$contributors["owner"]["name"]."</span></div>"
            ."<br/>"
            ."<div>Author</div>"
            ."<div><span style='color: #d7ba7d; font-weight: bold;'>".$contributors["author"]["name"]." Teams</span></div>";
            //."<div>Teams</div>";
            foreach($contributors["author"]["teams"] as $team) {
                $content .= "<div>"
                    ."<span style='color: #61afef; font-weight: bold;'>".$team["name"]."</span>"
                    ."<span> (".$team["role"].")</span>"
                    ."</div>";
            }
        $content .= "<br/>";
            foreach($contributors["contributors"] as $contibutor) {
                $content .= "<div>Contributions to <span style='color: #d7ba7d; font-weight: bold;'>".$contibutor["title"]."</span></div>";
                foreach($contibutor["teams"] as $team) {
                    $content .= "<div>"
                        ."<span style='color: #61afef; font-weight: bold;'>".$team["name"]."</span>"
                        ."<span> ".(isset($team["role"]) ? "(".$team["role"].")" : "")."</span>"
                        ."</div>";
                }
                $content .= "<br/>";
            }
        $content .= "<br/>"           
            ."</div>";

        $response = $this->downloadDocument($content, "text/html", "html", "kontak", false);

        return $response;
    }
}
