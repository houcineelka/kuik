<?php

namespace App\Models;

use App\Models\Scopes\WithCoordinatesScope;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Query\Expression;

class Listing extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'type',
        'category',
        'description',
        'location',
        'city',
        'neighborhood',
        'event_date',
        'private_detail',
        'status',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'location',
    ];

    protected static function booted(): void
    {
        static::addGlobalScope(new WithCoordinatesScope());
    }

    /**
     * Build a raw POINT(longitude, latitude) SQL expression for the location column.
     */
    public static function pointExpression(float $lat, float $lng): Expression
    {
        return new Expression(sprintf(
            'POINT(%s, %s)',
            number_format($lng, 7, '.', ''),
            number_format($lat, 7, '.', '')
        ));
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'event_date' => 'date',
            'latitude' => 'float',
            'longitude' => 'float',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return HasMany<ListingPhoto, $this>
     */
    public function photos(): HasMany
    {
        return $this->hasMany(ListingPhoto::class);
    }

    /**
     * @return HasMany<Claim, $this>
     */
    public function claims(): HasMany
    {
        return $this->hasMany(Claim::class);
    }
}
