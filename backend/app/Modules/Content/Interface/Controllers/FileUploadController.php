<?php

namespace App\Modules\Content\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Content\Interface\Requests\UploadFileRequest;
use App\Modules\Content\Application\FileUploadService;

class FileUploadController extends ApiController
{
    public function __construct(protected FileUploadService $fileUploadService) {}

    public function upload(UploadFileRequest $request)
    {
        $payload = $this->fileUploadService->store($request->file('file'), $request->user(), 'uploads');

        return $this->success('File uploaded successfully.', $payload, 201);
    }
}
