<?php

namespace DBService\validator;

use Laminas\Validator\AbstractValidator;

class Regex extends AbstractValidator
{
    const INVALID      = 'regexInvalid';
    const NOT_REGEX    = 'notRegex';

    /**
     * Validation failure message template definitions
     *
     * @var string[]
     */
    protected $messageTemplates = [
        self::INVALID      => 'Jenis input yang diberikan tidak valid',
        self::NOT_REGEX    => 'Input yang di masukan harus sesuai pola',
    ];

    /**
     * Options for this validator
     *
     * @var array
     */
    protected $options = [
        'pattern' => '',
        'notRegexMessage' => ''
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

        if(isset($options['notRegexMessage']) != '') {
            $this->messageTemplates[self::NOT_REGEX] = $options['notRegexMessage'];
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

        $pattern = $this->options['pattern'];
        $result = preg_replace($pattern, '', $value);

        if ($result !== '') {
            $this->error(self::NOT_REGEX);
            return false;
        }

        return true;
    }
}
