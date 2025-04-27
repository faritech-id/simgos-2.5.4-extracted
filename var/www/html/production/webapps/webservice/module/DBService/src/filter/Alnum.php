<?php

namespace DBService\filter;

use Laminas\Stdlib\StringUtils;
use Locale;
use Laminas\I18n\Filter\AbstractLocale;

class Alnum extends AbstractLocale
{
    /**
     * @var array
     */
    protected $options = [
        'locale'          => null,
        'allowCharacter' => ''
    ];

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
        if (! is_scalar($value) && ! is_array($value)) {
            return $value;
        }

        $allowCharacter = $this->options['allowCharacter'];
        $language   = Locale::getPrimaryLanguage($this->getLocale());

        if (! StringUtils::hasPcreUnicodeSupport()) {
            // POSIX named classes are not supported, use alternative a-zA-Z0-9 match
            $pattern = '/[^a-zA-Z0-9' . $allowCharacter . ']/';
        } elseif (in_array($language, ['ja', 'ko', 'zh'], true)) {
            // Use english alphabet
            $pattern = '/[^a-zA-Z0-9'  . $allowCharacter . ']/u';
        } else {
            // Use native language alphabet
            $pattern = '/[^\p{L}\p{N}' . $allowCharacter . ']/u';
        }

        return preg_replace($pattern, '', $value);
    }
}
