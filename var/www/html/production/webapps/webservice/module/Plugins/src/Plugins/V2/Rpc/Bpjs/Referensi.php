<?php
namespace Plugins\V2\Rpc\Bpjs;

class Referensi
{    
    private $controller;
	
	public function __construct($controller) 
	{
		$this->controller = $controller;
	}

	public function list() {
		$params = (array) $this->controller->getRequest()->getQuery();
	    $query = count($params) > 0 ? "?".http_build_query($params) : "";
	    $data = $this->controller->validateRequest($this->controller->sendRequest("referensi".$query));
	    if(isset($data['status'])) return $data;
	    $list = isset($data["list"]) ? $data["list"] : null;
	    $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
	    $data = $total > 0 ? $list : null;
	    return [
	        'success' => true
	        , 'total' => $total
	        , 'data' => $data
		];
	}

	public function poli() {
		$params = (array) $this->controller->getRequest()->getQuery();
		$query = isset($params["query"]) ? "?query=".$params["query"] : "";
		
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/poli'.$query));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function diagnosa() {
		$params = (array) $this->controller->getRequest()->getQuery();
		$query = isset($params["query"]) ? "?query=".$params["query"] : "";
		
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/diagnosa'.$query));		
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function procedure() {
		$params = (array) $this->controller->getRequest()->getQuery();
		$query = isset($params["query"]) ? $params["query"] : "";
		
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/procedure?query='.$query));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function kelasRawat() {
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/kelasRawat'));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function dokter() {
		$params = (array) $this->controller->getRequest()->getQuery();
		$query = isset($params["query"]) ? $params["query"] : "";
		
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/dokter?query='.$query));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function spesialistik() {
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/spesialistik'));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function ruangRawat() {
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/ruangRawat'));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function caraKeluar() {
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/caraKeluar'));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function pascaPulang() {
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/pascaPulang'));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	public function faskes() {
		$params = (array) $this->controller->getRequest()->getQuery();
		$nama = isset($params["nama"]) ? $params["nama"] : "";
		$jenis = isset($params["jenis"]) ? $params["jenis"] : "";
		$start = isset($params["start"]) ? $params["start"] : 0;
		$limit = isset($params["limit"]) ? $params["limit"] : 0;
		$data = $this->controller->validateRequest($this->controller->sendRequest('referensi/faskes?nama='.$nama.'&jenis='.$jenis.'&start='.$start.'&limit='.$limit));
		if(isset($data['status'])) return $data;
		$list = isset($data["list"]) ? $data["list"] : null;
		$total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
		$data = $total > 0 ? $list : null;
		return [
			'success' => true
			, 'total' => $total
			, 'data' => $data
		];
	}
	
	/* Pencarian data DPJP
	 * @parameter
	 *   $params array(
	 *		"jenisPelayanan" => value | Jenis Pelayanan (1. Rawat Inap, 2. Rawat Jalan)
	 *		, "tglPelayanan" => value | Tgl.Pelayanan/SEP (yyyy-mm-dd)
	 *		, "kodeSpesialis" => value | Kode Spesialis/Subspesialis see referensi spesialistik
	 * )
	 */
	public function dpjp() {
	    $params = (array) $this->controller->getRequest()->getQuery();
	    $query = count($params) > 0 ? "?".http_build_query($params) : "";
	    $data = $this->controller->validateRequest($this->controller->sendRequest("referensi/dpjp".$query));
	    if(isset($data['status'])) return $data;
	    $list = isset($data["list"]) ? $data["list"] : null;
	    $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
	    $data = $total > 0 ? $list : null;
	    return [
	        'success' => true
	        , 'total' => $total
	        , 'data' => $data
		];
	}
	
	/* 
	 * Pencarian data Propinsi
	 */
	public function propinsi() {
	    $data = $this->controller->validateRequest($this->controller->sendRequest("referensi/propinsi"));
	    if(isset($data['status'])) return $data;
	    $list = isset($data["list"]) ? $data["list"] : null;
	    $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
	    $data = $total > 0 ? $list : null;
	    return [
	        'success' => true
	        , 'total' => $total
	        , 'data' => $data
		];
	}
	
	/* Pencarian data Kabupaten
	 * @parameter
	 * $params array(
	 *		"kodePropinsi" => value
	 * )
	 */
	public function kabupaten() {
	    $params = (array) $this->controller->getRequest()->getQuery();
	    $query = count($params) > 0 ? "?".http_build_query($params) : "";
	    $data = $this->controller->validateRequest($this->controller->sendRequest("referensi/kabupaten".$query));
	    if(isset($data['status'])) return $data;
	    $list = isset($data["list"]) ? $data["list"] : null;
	    $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
	    $data = $total > 0 ? $list : null;
	    return [
	        'success' => true
	        , 'total' => $total
	        , 'data' => $data
		];
	}
	
	/* Pencarian data Kecamatan
	 * @parameter
	 * $params array(
	 *		"kodekabupaten" => value
	 * )
	 */
	public function kecamatan() {
	    $params = (array) $this->controller->getRequest()->getQuery();
	    $query = count($params) > 0 ? "?".http_build_query($params) : "";
	    $data = $this->controller->validateRequest($this->controller->sendRequest("referensi/kecamatan".$query));
	    if(isset($data['status'])) return $data;
	    $list = isset($data["list"]) ? $data["list"] : null;
	    $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
	    $data = $total > 0 ? $list : null;
	    return [
	        'success' => true
	        , 'total' => $total
	        , 'data' => $data
		];
	}
	
	/* Pencarian data Wilayah
	 * @parameter
	 * $params array(
	 *		"sesuai dgn parameternya masing2" => value,
	 *      "tipe" => value | 1. Propinsi, 2. Kabupaten, 3. Kecamatan
	 * )
	 */
	public function wilayah() {
	    $uris = [
	        1 => "referensi/propinsi",
	        2 => "referensi/kabupaten",
	        3 => "referensi/kecamatan"
	    ];
	    $params = (array) $this->controller->getRequest()->getQuery();
	    $uri = $uris[1];
	    if(isset($params["tipe"])) {
            if(isset($uris[$params["tipe"]])) $uri = $uris[$params["tipe"]];
	        unset($params["tipe"]);
	    }
	    $query = count($params) > 0 ? "?".http_build_query($params) : "";
	    $data = $this->controller->validateRequest($this->controller->sendRequest($uri.$query));
	    if(isset($data['status'])) return $data;
	    $list = isset($data["list"]) ? $data["list"] : null;
	    $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
	    $data = $total > 0 ? $list : null;
	    return [
	        'success' => true
	        , 'total' => $total
	        , 'data' => $data
		];
	}

	public function diagnosaPrb() {
        $data = $this->controller->validateRequest($this->controller->sendRequest("referensi/diagnosaPrb"));
        if(isset($data['status'])) return $data;
        $list = isset($data["list"]) ? $data["list"] : null;
        $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
        $data = $total > 0 ? $list : null;
        return [
            'success' => true
            , 'total' => $total
            , 'data' => $data
		];
    }

	public function obatGenerikPrb() {
        $params = (array) $this->controller->getRequest()->getQuery();
        $query = count($params) > 0 ? "?".http_build_query($params) : "";
        $data = $this->controller->validateRequest($this->controller->sendRequest("referensi/obatGenerikPrb".$query));
        if(isset($data['status'])) return $data;
        $list = isset($data["list"]) ? $data["list"] : null;
        $total = isset($data["count"]) ? $data["count"] : (isset($list) ? count($list) : 0);
        $data = $total > 0 ? $list : null;
        return [
            'success' => true
            , 'total' => $total
            , 'data' => $data
		];
    }
}