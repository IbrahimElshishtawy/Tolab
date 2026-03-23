<?php

namespace App\Modules\Auth\Resources;

use App\Modules\Auth\DTOs\AuthTokenData;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property AuthTokenData $resource
 */
class AuthResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'accessToken' => $this->resource->accessToken,
            'refreshToken' => $this->resource->refreshToken,
            'user' => UserIdentityResource::make($this->resource->user),
        ];
    }
}
