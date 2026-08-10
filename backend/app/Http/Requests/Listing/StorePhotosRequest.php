<?php

namespace App\Http\Requests\Listing;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;

class StorePhotosRequest extends FormRequest
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
            'photos' => ['required', 'array', 'min:1', 'max:3'],
            'photos.*' => ['required', 'image', 'mimes:jpeg,jpg,png,webp', 'max:5120'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $listing = $this->route('listing');

            if (! $listing) {
                return;
            }

            $existing = $listing->photos()->count();
            $incoming = count($this->file('photos', []));

            if ($existing + $incoming > 3) {
                $validator->errors()->add(
                    'photos',
                    "Ce signalement possède déjà {$existing} photo(s) ; 3 maximum au total."
                );
            }
        });
    }
}
