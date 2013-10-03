#define MTMath_E 2.718281828459045f
  
#define MTMath_PI 3.141592653589793f


/**
 * A quadratic easing in function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuadIn(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength;
    return value0 + (factor * factor * valueDelta);
}

/**
 * A quadratic easing out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuadOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength;
    return value0 + factor * (factor - 2.f) * -valueDelta;
}

/**
 * A quadratic easing in/out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuadInOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / (changeLength / 2.f);
    if (factor < 1.f)
    {
        return value0 + factor * factor * valueDelta / 2.f;
    }
    else
    {
        return value0 + ((factor - 1.f) * (factor - 3.f) - 1.f) * -valueDelta 
            / 2.f;
    }
}

/**
 * A cubic easing in function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseCubicIn(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength;
    return value0 + (factor * factor * factor * valueDelta);
}

/**
 * A cubic easing out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseCubicOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength - 1.f;
    return value0 + (factor * factor * factor + 1.f) * valueDelta;
}

/**
 * A cubic easing in/out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseCubicInOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / (changeLength / 2.f);
    if (factor < 1.f)
    {
        return value0 + factor * factor * factor * valueDelta / 2.f;
    }
    else
    {
        factor -= 2.f;
        return value0 + (factor * factor * factor + 2.f) * valueDelta / 2.f;
    }
}

/**
 * A quart easing in function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuartIn(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength;
    return value0 + (factor * factor * factor * factor * valueDelta);
}

/**
 * A quart easing out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuartOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength - 1.f;
    return value0 + (factor * factor * factor * factor - 1.f) * -valueDelta;
}

/**
 * A quart easing in/out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuartInOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / (changeLength / 2.f);
    if (factor < 1.f)
    {
        return value0 + factor * factor * factor * factor * valueDelta / 2.f;
    }
    else
    {
        factor -= 2.f;
        return value0 + (factor * factor * factor * factor - 2.f) * -valueDelta 
            / 2.f;
    }
}

/**
 * A quint easing in function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuintIn(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength;
    return value0 + (factor * factor * factor * factor * factor * valueDelta);
}

/**
 * A quint easing out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuintOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / changeLength - 1.f;
    return value0 + (factor * factor * factor * factor * factor + 1.f) 
        * valueDelta;
}

/**
 * A quint easing in/out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseQuintInOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    float factor = changeOffset / (changeLength / 2.f);
    if (factor < 1.f)
    {
        return value0 + factor * factor * factor * factor * factor * valueDelta 
            / 2.f;
    }
    else
    {
        factor -= 2.f;
        return value0 + (factor * factor * factor * factor * factor + 2.f) 
            * valueDelta / 2.f;
    }
}

/**
 * A sinusoidal easing in function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseSineIn(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    return value0 + valueDelta + cosf(MTMath_PI / 2.f * changeOffset 
        / changeLength) * -valueDelta;
}

/**
 * A sinusoidal easing out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseSineOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    return value0 + sinf(MTMath_PI / 2.f * changeOffset / changeLength) 
        * valueDelta;
}

/**
 * A sinusoidal easing in/out function.
 * 
 * @param value0
 *            the initial value.
 * @param valueDelta
 *            the change/delta in value.
 * @param changeLength
 *            the duration required to reach the change.
 * @param changeOffset
 *            the current time for which the value is being processed
 */
CG_INLINE float
MTEaseSineInOut(float value0, float valueDelta, float changeLength, 
    float changeOffset)
{
    return value0 + (cosf(MTMath_PI * changeOffset / changeLength) - 1.f) 
        * -valueDelta / 2.f;
}