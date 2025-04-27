<?php

namespace DBService\validator;

class Number extends Alnum
{
    const INVALID      = 'numberInvalid';
    const NOT_NUMBER    = 'notNumber';

    /**
     * Validation failure message template definitions
     *
     * @var string[]
     */
    protected $messageTemplates = [
        self::INVALID      => 'Jenis input yang diberikan tidak valid',
        self::NOT_NUMBER    => 'Input yang di masukan harus berisi angka',
    ];

    /**
     * Options for this validator
     *
     * @var array
     */
    protected $options = [
        'allowCharacter' => '',
        'notNumberMessage' => ''
    ];

    /**
     * Sets one or multiple options
     *
     * @param  array|Traversable $options Options to set
     * @return $this Provides fluid interface
     */
    public function setOptions($options = [])
    {
        parent::setOptions($options);

        if(isset($options['notNumberMessage']) != '') {
            $this->messageTemplates[self::NOT_NUMBER] = $options['notNumberMessage'];
            $this->abstractOptions["messageTemplates"] = $this->messageTemplates;
        }

        return $this;
    }

    /**
     * Returns true if and only if $value contains only alphabetic and digit characters
     *
     * @param  int|float|string $value
     * @return bool
     */
    public function isValid($value)
    {
        if (! is_string($value) && ! is_int($value) && ! is_float($value)) {
            $this->error(self::INVALID);
            return false;
        }

        $allowCharacter = $this->options['allowCharacter'];
        $pattern = '/[0-9'  . $allowCharacter . ']/u';
        $result = preg_replace($pattern, '', $value);

        if ($result !== '') {
            $this->error(self::NOT_NUMBER);
            return false;
        }

        return true;
    }
}
