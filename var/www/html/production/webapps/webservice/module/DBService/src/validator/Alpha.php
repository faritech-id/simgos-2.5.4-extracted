<?php

namespace DBService\validator;

class Alpha extends Alnum
{
    const INVALID      = 'alphaInvalid';
    const NOT_ALPHA    = 'notAlpha';

    /**
     * Validation failure message template definitions
     *
     * @var string[]
     */
    protected $messageTemplates = [
        self::INVALID      => 'Jenis input yang diberikan tidak valid',
        self::NOT_ALPHA    => 'Input yang di masukan harus berisi huruf',
    ];

    /**
     * Options for this validator
     *
     * @var array
     */
    protected $options = [
        'allowCharacter' => '',
        'notAlphaMessage' => ''
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

        if(isset($options['notAlphaMessage']) != '') {
            $this->messageTemplates[self::NOT_ALPHA] = $options['notAlphaMessage'];
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
        $pattern = '/[a-zA-Z'  . $allowCharacter . ']/u';
        $result = preg_replace($pattern, '', $value);

        if ($result !== '') {
            $this->error(self::NOT_ALPHA);
            return false;
        }

        return true;
    }
}
