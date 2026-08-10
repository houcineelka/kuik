<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ListingMatch extends Model
{
    protected $table = 'matches';

    const UPDATED_AT = null;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'lost_listing_id',
        'found_listing_id',
        'score',
        'status',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'score' => 'float',
        ];
    }

    /**
     * @return BelongsTo<Listing, $this>
     */
    public function lostListing(): BelongsTo
    {
        return $this->belongsTo(Listing::class, 'lost_listing_id');
    }

    /**
     * @return BelongsTo<Listing, $this>
     */
    public function foundListing(): BelongsTo
    {
        return $this->belongsTo(Listing::class, 'found_listing_id');
    }
}
