# These tests PASS

SCENARIO "Rambutans are red" \
    GIVEN a_rome_apple  \
    WHEN fruit_is rambutan \
    THEN the_colors_agree

SCENARIO "Strawberries are red" \
    GIVEN a_rome_apple \
    WHEN fruit_is strawberry \
    THEN the_colors_agree
