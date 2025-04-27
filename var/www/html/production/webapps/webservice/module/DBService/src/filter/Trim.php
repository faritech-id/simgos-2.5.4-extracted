<?php

namespace DBService\filter;

use Laminas\I18n\Filter\AbstractLocale;

class Trim extends AbstractLocale
{
    /**
     * Defined by Laminas\Filter\FilterInterface
     *
     * Returns $value as string with all non-alphanumeric characters removed
     *
     * @param  string|array $value
     * @return string|array
     */
    public function filter($value)
    {
        return trim($value);
    }
}
