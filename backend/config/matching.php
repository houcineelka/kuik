<?php

return [

    // Max distance (km) considered for a match; beyond this, the distance score is 0.
    'distance_threshold_km' => (float) env('MATCHING_DISTANCE_THRESHOLD_KM', 5),

    // Max day gap between event_dates considered for a match; beyond this, the date score is 0.
    'date_window_days' => (int) env('MATCHING_DATE_WINDOW_DAYS', 7),

    // Minimum total score (0-100) required to persist a match.
    'match_threshold' => (float) env('MATCHING_SCORE_THRESHOLD', 50),

    // Weights should sum to 100.
    'weights' => [
        'category' => (float) env('MATCHING_WEIGHT_CATEGORY', 40),
        'distance' => (float) env('MATCHING_WEIGHT_DISTANCE', 30),
        'date' => (float) env('MATCHING_WEIGHT_DATE', 20),
        'description' => (float) env('MATCHING_WEIGHT_DESCRIPTION', 10),
    ],

];
