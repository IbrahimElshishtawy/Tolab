<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\StoreQuizPortalRequest;
use App\Modules\StaffPortal\Resources\QuizPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class QuizController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/quizzes",
     *     summary="index action in QuizController",
     *     tags={"StaffPortal"},
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
    public function index(Request $request)
    {
        return $this->success('Quizzes retrieved successfully.', QuizPortalResource::collection($this->service->quizzes($request->user())));
    }

    public function store(StoreQuizPortalRequest $request)
    {
        return $this->success('Quiz created successfully.', QuizPortalResource::make($this->service->createQuiz($request->user(), $request->validated())), 201);
    }
}
