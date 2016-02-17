float smootherstep(float t) {
    return t = t*t*t * (t * (6.0*t - 15.0) + 10.0);
}

int managed_time() {
    return millis() + TimeOffset;
}
