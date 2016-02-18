float smootherstep(float t) {
    return t = t*t*t * (t * (6.0*t - 15.0) + 10.0);
}

int managed_time() {
    return (int)(frameCount * 33.33333);
    //return millis() + TimeOffset;
}
