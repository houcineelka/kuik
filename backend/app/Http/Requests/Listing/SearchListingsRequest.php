<?php

namespace App\Http\Requests\Listing;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class SearchListingsRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'lat' => ['nullable', 'numeric', 'between:-90,90', 'required_with:lng,radius_km'],
            'lng' => ['nullable', 'numeric', 'between:-180,180', 'required_with:lat,radius_km'],
            'radius_km' => ['nullable', 'numeric', 'between:0.1,500'],
            'category' => ['nullable', 'string', 'max:255'],
            'type' => ['nullable', 'in:lost,found'],
            'city' => ['nullable', 'string', 'max:255'],
            'neighborhood' => ['nullable', 'string', 'max:255'],
            'date_from' => ['nullable', 'date'],
            'date_to' => ['nullable', 'date', 'after_or_equal:date_from'],
            'keyword' => ['nullable', 'string', 'max:255'],
        ];
    }
}
