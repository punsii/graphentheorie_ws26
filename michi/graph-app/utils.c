#include "utils.h"

#include <stdlib.h>

i32 rand_between_i32(i32 min, i32 max)
{
    f32 range = (f32)max - (f32)min;
    f32 r     = (f32)rand() / (f32)RAND_MAX; /* random value between [0.0,1.0] */
    return (i32)(range * r + (f32)min);
}
