<?php

namespace App\Core\Exceptions;

use Exception;

class ApiException extends Exception
{
    public function __construct(
        string $message,
        protected array $errors = [],
        protected int $status = 422
    ) {
        parent::__construct($message, $status);
    }

    public function getErrors(): array
    {
        return $this->errors;
    }

    public function getStatus(): int
    {
        return $this->status;
    }
}
