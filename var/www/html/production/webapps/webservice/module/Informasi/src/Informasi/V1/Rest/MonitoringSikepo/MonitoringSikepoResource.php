<?php
namespace Informasi\V1\Rest\MonitoringSikepo;

use Laminas\ApiTools\ApiProblem\ApiProblem;
use DBService\Resource;
use DBService\DatabaseService;
use Zend\Paginator\Adapter;
use Zend\Paginator\Paginator;

class MonitoringSikepoResource extends Resource
{
	public function __construct() {
		parent::__construct();
		$this->dbs = DatabaseService::get("SIMpel");
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
     * @param  array|Parameters $params
     * @return ApiProblem|mixed
     */
    public function fetchAll($params = [])
    {
		if (isset($params->MONITORING)) {
			$tanggal = isset($params->TANGGAL) ? $params->TANGGAL : '';
			$carakeluar = isset($params->CARAKELUAR) ? $params->CARAKELUAR : '0';
			$ruangan = isset($params->RUANGAN) ? $params->RUANGAN : '0';
			$laporan = isset($params->LAPORAN) ? $params->LAPORAN : '0';
			$carabayar = isset($params->CARABAYAR) ? $params->CARABAYAR : '0';
			$dokter = isset($params->DOKTER) ? $params->DOKTER : '0';
			$statuslos = isset($params->STATUSLOS) ? $params->STATUSLOS : '0';
			$statustarif = isset($params->STATUSTARIF) ? $params->STATUSTARIF : '0';
			$rencanapulang = isset($params->RENCANAPULANG) ? $params->RENCANAPULANG : '0';
			$pagess = isset($params->page) ? $params->page : 1;
			$pcari = isset($params->PCARI) ? $params->PCARI : '';		
			$statusgrouping = isset($params->STATUSGROUPING) ? $params->STATUSGROUPING : '0';		
            $severitylevel = strval(isset($params->PSEVERITY) ? $params->PSEVERITY : '0');		
			$adapter = $this->dbs->getAdapter();
			$stmt = $adapter->query("CALL informasi.monitoringPasienDirawatSikepo(?,?,?,?,?,?,?,?,?,?,?,?)");
			$info = $stmt->execute(array($tanggal, $carakeluar, $ruangan, $laporan, $carabayar, $dokter, $statuslos, $statustarif, $rencanapulang, $pcari, $statusgrouping, $severitylevel));
			$data = array();
			$page = array();
			foreach ($info as $row) {			
				$data[] = $row;
			}
			$paging = new Paginator(new Adapter\ArrayAdapter($data));
			$paging->setCurrentPageNumber($pagess)
                      ->setItemCountPerPage(25);
			foreach ($paging as $pag) {			
				$page[] = $pag;
			}
			return array(
				'success' => true,
				'total' => count($data),
				'data' => $page
			);
		}
		
		if (isset($params->KASUS_SEJENIS)) {
			$pcodecbg = isset($params->PCODE_CBG) ? $params->PCODE_CBG : '';
			$pagess = isset($params->page) ? $params->page : 1;
			$adapter = $this->dbs->getAdapter();
			$stmt = $adapter->query("CALL informasi.historySeveritySikepo(?)");
			$info = $stmt->execute(array($pcodecbg));
			$data = array();
			$page = array();
			foreach ($info as $row) {			
				$data[] = $row;
			}
			$paging = new Paginator(new Adapter\ArrayAdapter($data));
			$paging->setCurrentPageNumber($pagess)
                      ->setItemCountPerPage(25);
			foreach ($paging as $pag) {			
				$page[] = $pag;
			}
			return array(
				'success' => true,
				'total' => count($data),
				'data' => $page
			);
		}
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
     * Patch (partial in-place update) a collection or members of a collection
     *
     * @param  mixed $data
     * @return ApiProblem|mixed
     */
    public function patchList($data)
    {
        return new ApiProblem(405, 'The PATCH method has not been defined for collections');
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
        return new ApiProblem(405, 'The PUT method has not been defined for individual resources');
    }
}
