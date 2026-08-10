<?php

namespace App\Models\Scopes;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Scope;
use Illuminate\Support\Facades\DB;

class WithCoordinatesScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        $table = $model->getTable();

        $builder->addSelect([
            "{$table}.*",
            DB::raw("ST_Y({$table}.location) as latitude"),
            DB::raw("ST_X({$table}.location) as longitude"),
        ]);
    }
}
