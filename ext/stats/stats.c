#include "ruby.h"
#include <unistd.h>
#include <time.h>
#include <sys/ioctl.h>

unsigned int PAGESIZE ;
unsigned int TICKS ;

VALUE statm_memory(VALUE obj, VALUE pid) {
	int _pid = FIX2INT(pid) ;
	if (_pid < 0) return Qnil ;

	char _path[22] ;
	sprintf(_path, "/proc/%d/statm", _pid) ;

	FILE *f = fopen(_path, "r") ;
	if (!f) return Qnil ;

	unsigned int resident, shared ;
	char status = fscanf(f, "%*u %u %u", &resident, &shared) ;
	fclose(f) ;

	if (status != 2) return Qnil ;

	unsigned int v = resident - shared ;
	return UINT2NUM(v) ;
}

VALUE ps_times(VALUE obj, VALUE pid) {
	int _pid = FIX2INT(pid) ;
	if (_pid < 0) return Qnil ;

	char _path[22] ;
	sprintf(_path, "/proc/%d/stat", _pid) ;

	FILE *f = fopen(_path, "r") ;
	if (!f) return Qnil ;

	unsigned long utime, stime ;

	char status = fscanf(f, "%*llu (%*[^)]%*[)] %*c %*d %*d %*d %*d %*d %*u %*lu %*lu %*lu %*lu %lu %lu", &utime, &stime) ;
	fclose(f) ;

	if (status != 2) return Qnil ;
	float total_time = (utime + stime) / (float)TICKS ;

	return rb_float_new(total_time) ;
}

VALUE clock_monotonic(VALUE obj) {
	struct timespec tv ;
	clock_gettime(CLOCK_MONOTONIC, &tv) ;
	long double time = tv.tv_sec + tv.tv_nsec / 1000000000.0 ;

	return rb_float_new(time) ;
}

VALUE winWidth(VALUE obj) {
	struct winsize w ;
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) ;
	return INT2NUM(w.ws_col) ;
}

void Init_stats() {
	PAGESIZE = sysconf(_SC_PAGESIZE) ;
	TICKS = sysconf(_SC_CLK_TCK) ;

	VALUE sunburst = rb_define_module("Sunburst") ;
	rb_define_const(sunburst, "PAGESIZE", UINT2NUM(PAGESIZE)) ;
	rb_define_const(sunburst, "TICKS", UINT2NUM(TICKS)) ;

	rb_define_module_function(sunburst, "get_mem", statm_memory, 1) ;
	rb_define_module_function(sunburst, "get_times", ps_times, 1) ;
	rb_define_module_function(sunburst, "clock_monotonic", clock_monotonic, 0) ;

	rb_define_module_function(sunburst, "win_width", winWidth, 0) ;
}
