<?php

namespace App\Modules\Content\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Content\Requests\UploadFileRequest;
use App\Modules\Content\Services\FileUploadService;

class FileUploadController extends ApiController
{
    public function __construct(protected FileUploadService $fileUploadService)
    {
    }

    public function upload(UploadFileRequest $request)
    {
        $payload = $this->fileUploadService->store($request->file('file'), $request->user(), 'uploads');

        return $this->success('File uploaded successfully.', $payload, 201);
    }
}
