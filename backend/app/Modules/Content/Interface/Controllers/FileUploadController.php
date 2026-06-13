<?php

namespace App\Modules\Content\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Content\Interface\Requests\UploadFileRequest;
use App\Modules\Content\Application\FileUploadService;

class FileUploadController extends ApiController
{
    public function __construct(protected FileUploadService $fileUploadService) {}

        /**
     * @OA\Post(
     *     path="/api/files/upload",
     *     summary="upload action in FileUploadController",
     *     tags={"Content"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"file"},
     *             @OA\Property(property="file", type="string", description="Rules: required, file, max:10240, mimes:pdf,doc,docx,ppt,pptx,xls,xlsx,csv,jpg,jpeg,png,zip,rar"),
     *             @OA\Property(property="category", type="string", description="Rules: nullable, string, max:80")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
    public function upload(UploadFileRequest $request)
    {
        $payload = $this->fileUploadService->store($request->file('file'), $request->user(), 'uploads');

        return $this->success('File uploaded successfully.', $payload, 201);
    }
}
