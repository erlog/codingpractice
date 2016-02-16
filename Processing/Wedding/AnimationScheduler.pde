public class AnimationScheduler{
    private List<AnimatedElement> Anims = new ArrayList<AnimatedElement>();
    private List<AnimatedElement> Expired = new ArrayList<AnimatedElement>();

    public void add(AnimatedElement element) {
        Anims.add(element);
    }

    public List<AnimatedElement> get_current_elements() {
        List<AnimatedElement> current_elements = new ArrayList<AnimatedElement>();
        for(AnimatedElement anim : Anims) {
            if(managed_time() >= anim.start_time) {
                current_elements.add(anim);
            }

            if(anim.finished) { Expired.add(anim); }
        }

        for(AnimatedElement anim : Expired) { Anims.remove(anim); }

        Expired.clear();
        return current_elements;
    }
}

