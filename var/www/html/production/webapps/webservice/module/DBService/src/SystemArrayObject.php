<?php
namespace DBService;

use Laminas\Stdlib\ArrayObject;

class SystemArrayObject extends ArrayObject
{
    protected $title = "";
	protected $fields = [];
    protected $map = false;
	private $allowFirstKey = [
		"ID" => 1, "NOMOR" => 1, "NOPEN" => 1, "NORM" => 1, "NIP" => 1, "KODE"
    ];
	private $mapToFields = [];
	private $fieldToMaps = [];

	/**
	 * Constructor
	 *
	 * @param array  $input
	 * @param int    $flags
	 * @param string $iteratorClass
	 */
	public function __construct($input = [], $flags = self::STD_PROP_LIST, $iteratorClass = 'ArrayIterator')
	{
	    parent::__construct($input, $flags, $iteratorClass);	    
	    $this->initMapFields();
	}

    public function addField($key, $val) {
        if(!isset($this->fields[$key])) $this->fields[$key] = $val;
    }

    public function setTitle($title) {
        $this->title = $title;
    }

    public function useMap($val = false) {
        $this->map = $val;
    }

    public function isUseMap() {
        return $this->map;
    }

	private function initMapFields() {
	    foreach($this->fields as $key => $val) {
            $setMap = false;
	        if(is_array($val)) {
	            if(isset($val["MAP"])) {
	                $this->fieldToMaps[$key] = $val["MAP"];
	                $this->mapToFields[$val["MAP"]] = $key;
                    $setMap = true;
	            }
	        }
            if($this->map && !$setMap) {
                $this->fieldToMaps[$key] = $key;
	                $this->mapToFields[$key] = $key;
            }
	    }
	}
	
	public function getID() {
		return $this->get('ID');
	}
	
	public function get($name) {
		return isset($this->storage[$name]) ? $this->storage[$name] : null;
	}
	
	public function set($name, $val) {
		$this->storage[$name] = $val;
	}
	
	/**
     * Exchange the array for another one.
     *
     * @param  array|ArrayObject $data
     * @return array
     */
    public function exchangeArray($data)
    {
        if($this->map) return $this->exchangeArrayFromMap($data);
        if (!is_array($data) && !is_object($data)) throw new Exception\InvalidArgumentException('Passed variable is not an array or object, using empty array instead');
        if (is_object($data) && ($data instanceof self || $data instanceof \ArrayObject)) $data = $data->getArrayCopy();
        if (!is_array($data)) $data = (array) $data;

        $storage = $this->storage;
		
		foreach($data as $key => $val) {
			if(count($this->fields) == 0) return $storage;
			if(isset($this->fields[$key])) {
                $field = $this->fields[$key];
                $filtered = false;
                if(isset($field["FILTERS"])) {
                    $filters = $field["FILTERS"];
                    if(is_array($filters)) {
                        foreach($filters as $f) {
                            $inputFilter = new $f["NAME"]();
                            if(isset($f["OPTIONS"])) $inputFilter->setOptions($f["OPTIONS"]);
                            if(!is_null($val)) {
                                $val = $inputFilter->filter($val);
                                $this->storage[$key] = $val;
                                $filtered = true;
                            }
                        }
                    }
                }
                if(!$filtered) {
                    if(!is_null($val)) $this->storage[$key] = $val;
                }
			}
		}

        return $storage;
    }

	public function getFilterFields($fields) {
		$filterFields = array();
		if (!is_array($fields) && !is_object($fields)) throw new Exception\InvalidArgumentException('Passed variable is not an array or object, using empty array instead');
		if (!is_array($fields)) $fields = (array) $fields;
		foreach($fields as $f) {
			if(isset($this->fields[$f])) $filterFields[] = $f;
		}		
        return $filterFields;
	}
	
	public function getIdKeys() {
		$keys = [];
		$keyFirstName = "";
		
		foreach($this->fields as $key => $val) {
			if($keyFirstName == "") $keyFirstName = $key;				
			if(is_array($val)) {
				if(isset($val["isKey"])) $keys[] = $key;
			}
		}
		
		if(count($keys) == 0) {
			if(isset($this->allowFirstKey[$keyFirstName])) $keys[] = $keyFirstName;
		}
		
		return $keys;
	}
	
	public function getDataWithDescription($data) {
		$data = is_array($data) ? $data : (array) $data;
		$desciptions = [];
		
		foreach($data as $key => $val) {
			if(isset($this->fields[$key])) {
				if(is_array($this->fields[$key])) {
					$desciptions[$key] = $this->fields[$key];
					$desciptions[$key]["NILAI"] = $val;
				} else {				
					$desciptions[$key]["NAMA"] = ucwords(strtolower($key));
					$desciptions[$key]["NILAI"] = $val;
				}
			}
		}
		
		return $desciptions;
	}

	/**
     * Exchange the array for another one.
     *
     * @param  array|ArrayObject $data
     * @return array
     */
    public function exchangeArrayFromMap($data)
    {
        if (!is_array($data) && !is_object($data)) throw new Exception\InvalidArgumentException('Passed variable is not an array or object, using empty array instead');
        if (is_object($data) && ($data instanceof self || $data instanceof \ArrayObject)) $data = $data->getArrayCopy();
        if (!is_array($data)) $data = (array) $data;
               
        $storage = $this->storage;
        
        if(count($this->mapToFields) == 0) return $this->exchangeArray($data);

        foreach($data as $key => $val) {
            if(count($this->fields) == 0) return $storage;
			if(isset($this->mapToFields[$key])) $key = $this->mapToFields[$key];
			if(isset($this->fields[$key])) {
                $field = $this->fields[$key];
                $filtered = false;
                if(isset($field["FILTERS"])) {
                    $filters = $field["FILTERS"];
                    if(is_array($filters)) {
                        foreach($filters as $f) {
                            $inputFilter = new $f["NAME"]();
                            if(isset($f["OPTIONS"])) $inputFilter->setOptions($f["OPTIONS"]);
                            if(!is_null($val)) {
                                $val = $inputFilter->filter($val);
                                $this->storage[$key] = $val;
                                $filtered = true;
                            }
                        }
                    }
                }
                if(!$filtered) {
                    if(!is_null($val)) $this->storage[$key] = $val;
                }
			}
		}
        
        return $storage;
    }
    
    /**
     * Exchange the array for another one.
     *
     * @param  array|ArrayObject $data
     * @return array
     */
    public function toArrayFieldToMap($data)
    {
        if (!is_array($data) && !is_object($data)) throw new Exception\InvalidArgumentException('Passed variable is not an array or object, using empty array instead');
        if (is_object($data) && ($data instanceof self || $data instanceof \ArrayObject)) $data = $data->getArrayCopy();
        if (!is_array($data)) $data = (array) $data;
        
        if(count($this->fieldToMaps) == 0) return $data;
        
        $return = [];
        
        foreach($data as $key => $val) {
            if(isset($this->fieldToMaps[$key])) {
                $fieldName = $this->fieldToMaps[$key];
                $return[$fieldName] = $val;
            }
        }
        
        return $return;
    }

    public function setRequiredFields($value = false, $fields = [], $fromMap = false) {
        foreach($this->fields as $key => &$val) {
            if(is_array($val)) {
                foreach($fields as $f) {
                    if($key == $f) {
                        if($value) $val["REQUIRED"] = $value;
                        else unset($val["REQUIRED"]);
                    }
                }
            }
        }
    }
    
    public function getNotValidEntity($data, $fromMap = false, $method = "POST") {
        //if($fromMap || $this->map) $this->exchangeArrayFromMap($data);
        //else $this->exchangeArray($data);
        
        $return = [];
        //$data = $this->getArrayCopy();
        $data = is_array($data) ? $data : (array) $data;
        foreach($this->fields as $key => $val) {
            if($this->map) {
                if(isset($this->fieldToMaps[$key])) $key = $this->fieldToMaps[$key];
            }
            if(is_array($val)) {
                $desc = empty($val["DESCRIPTION"]) ? $key : $val["DESCRIPTION"];
                if($this->title != "") $desc .= " ".$this->title;
                if(isset($val["REQUIRED"]) && $method == "POST") {
                    if(!isset($data[$key])) $return[] = $desc." harus di isi";
                    else {
                        $empty = false;
                        if(is_null($data[$key])) $empty = true;                        
                        else {
                            if($data[$key] == "") {
                                if(!is_int($data[$key])) $empty = true;
                            }
                        }
                        if(is_bool($data[$key])) $empty = false;
                        if($empty) $return[] = $desc." harus di isi";
                    }
                }
                if(isset($val["VALIDATORS"]) && isset($data[$key])) {
                    $validators = $val["VALIDATORS"];
                    if(is_array($validators)) {
                        foreach($validators as $v) {
                            $inputValidator = new $v["NAME"](null);
                            if(isset($v["OPTIONS"])) $inputValidator->setOptions($v["OPTIONS"]);
                            if(!$inputValidator->isValid($data[$key])) {
                                $messages = $inputValidator->getMessages();
                                foreach($messages as $m => $v) {
                                    $return[] = $desc.": ".$v;
                                }
                            }
                        }
                    }
                }
                if(isset($val["VALIDATOR"])) {
                    $validator = new $val["VALIDATOR"]();
                    if(!$validator->isValid($data[$key])) $return[] = $desc." belum benar";
                }
            }
        }
        
        return count($return) == 0 ? [] : [ 
            "messages" => implode("\r\n", $return)
        ];
    }

    public function getFieldWithAlias($alias, $delimiter = "_") {
        $fields = [];

        foreach($this->fields as $key => $val) {
            $fields[$alias.$delimiter.$key] = $key;
        }

        return $fields;
    }
}
