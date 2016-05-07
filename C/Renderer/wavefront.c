//TODO: add a ruby interpreter to import wavefront files
void load_model(char* object_name) {
    VALUE klass = rb_const_get(rb_cObject, rb_intern("Wavefront"));
    VALUE rb_object_name = rb_str_new2(object_name);
    VALUE wavefront = rb_funcall(klass, rb_intern("from_object"), 1, rb_object_name);
    return;
}
