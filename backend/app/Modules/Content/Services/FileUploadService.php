<?php

namespace App\Modules\Content\Services;

use App\Modules\UserManagement\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class FileUploadService
{
    public function store(UploadedFile $file, User $user, string $directory = 'uploads'): array
    {
        $name = Str::uuid()->toString().'_'.Str::slug(pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME));
        $path = $file->storeAs($directory.'/'.now()->format('Y/m'), $name.'.'.$file->getClientOriginalExtension(), 'public');

        return [
            'file_url' => Storage::disk('public')->url($path),
            'file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getClientMimeType() ?: $file->getMimeType(),
            'size' => $file->getSize(),
            'uploaded_by' => $user->id,
        ];
    }
}
