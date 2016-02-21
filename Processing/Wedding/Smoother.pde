
HashMap initialize_smoothers() {
    HashMap smoother_map = new HashMap();
    smoother_map.put("NONE", new SmootherNone());
    smoother_map.put("SMOOTHERSTEP", new SmootherSmootherStep());
    return smoother_map;
}

interface Smoother {
    public float smooth(float t);
}

public class SmootherNone implements Smoother {
    public float smooth(float t) {
        return t;
    }
}

public class SmootherSmootherStep implements Smoother {
    public float smooth(float t) {
        return t = t*t*t * (t * (6.0*t - 15.0) + 10.0);
    }
}

