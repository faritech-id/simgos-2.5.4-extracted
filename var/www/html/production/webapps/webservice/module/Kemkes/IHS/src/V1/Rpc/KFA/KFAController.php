<?php
namespace Kemkes\IHS\V1\Rpc\KFA;
use Kemkes\IHS\RPCResource;

class KFAController extends RPCResource
{
    public function __construct($controller)
    {
        parent::__construct($controller);
        $config = $controller->get('Config');
        $config = $config['services']['KemkesService'];
        $config = $config['IHS'];
        $kfa = $config['kfa'];

        $this->url = $kfa['url'];

        $this->resourceType = "products";
        $this->title = 'KFA';
        $this->paramsQuery = [
            'kode' => '?identifier=kfa&code=',
            'price' => '/farmalkes-price?code=',
            'name' => '/all?product_type=farmasi&keyword='
        ];
    }

    public function searchAction(){
        $method = $this->request->getMethod();
		$params = (array) $this->getRequest()->getQuery();

        if(isset($params["_dc"])) unset($params["_dc"]);
        if(isset($params["start"])) unset($params["start"]);
        if(isset($params["limit"])) {
            $params["size"] = $params["limit"];
            unset($params["limit"]);
        }
        $paremeter = $this->setParamsIhs($params);
        $return = $this->sendToIhs($this->resourceType."".$paremeter);
        $return = is_array($return) ? $return : (array) $return;
        if(isset($return['items'])){
            if(isset($return['items']->data)){
                $data = $return['items']->data;
                if(count($data) > 0)
                $return["entry"] = $data;
            }
        }
        return  (array) $return;
    }
}
