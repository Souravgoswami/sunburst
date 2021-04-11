#include "ruby.h"
#include <unistd.h>
#include <time.h>
#include <sys/ioctl.h>
#include <sys/sysinfo.h>

unsigned int PAGESIZE ;
unsigned int TICKS ;

VALUE statm_memory(volatile VALUE obj, volatile VALUE pid) {
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

VALUE ps_stat(volatile VALUE obj, volatile VALUE pid) {
	int _pid = FIX2INT(pid) ;
	if (_pid < 0) return rb_str_new_cstr("") ;

	char _path[22] ;
	sprintf(_path, "/proc/%d/stat", _pid) ;

	FILE *f = fopen(_path, "r") ;

	if (!f) return rb_ary_new() ;

	// For this info
	// follow https://man7.org/linux/man-pages/man5/proc.5.html
	char state[1] ;
	int ppid, processor ;
	long unsigned utime, stime ;
	long num_threads ;

	char status = fscanf(
		f, "%*llu (%*[^)]%*[)] %1s "
		"%d %*d %*d %*d %*d %*u "
		"%*lu %*lu %*lu %*lu %lu %lu "
		"%*ld %*ld %*ld %*ld %ld",
		&state, &ppid, &utime, &stime, &num_threads
	) ;

	fclose(f) ;

	if (status != 5) return rb_ary_new() ;

	return rb_ary_new_from_args(5,
		INT2NUM(ppid),
		ULONG2NUM(utime),
		ULONG2NUM(stime),
		LONG2NUM(num_threads),
		rb_str_new(state, 1)
	) ;
}

VALUE clock_monotonic(volatile VALUE obj) {
	struct timespec tv ;
	clock_gettime(CLOCK_MONOTONIC, &tv) ;
	float time = tv.tv_sec + tv.tv_nsec / 1000000000.0 ;

	return rb_float_new(time) ;
}

VALUE winWidth(volatile VALUE obj) {
	struct winsize w ;
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) ;
	return INT2NUM(w.ws_col) ;
}

VALUE totalRAM(volatile VALUE obj) {
	struct sysinfo buf ;
	char status = sysinfo(&buf) ;

	if (status != 0) return Qnil ;

	return rb_funcall(
		ULONG2NUM(buf.totalram),
		rb_intern("*"),
		1,
		ULONG2NUM(buf.mem_unit)
	) ;
}

void Init_stats() {
	PAGESIZE = sysconf(_SC_PAGESIZE) ;
	TICKS = sysconf(_SC_CLK_TCK) ;

	VALUE sunburst = rb_define_module("Sunburst") ;
	rb_define_const(sunburst, "PAGESIZE", UINT2NUM(PAGESIZE)) ;
	rb_define_const(sunburst, "TICKS", UINT2NUM(TICKS)) ;

	rb_define_module_function(sunburst, "get_mem", statm_memory, 1) ;
	rb_define_module_function(sunburst, "clock_monotonic", clock_monotonic, 0) ;

	rb_define_module_function(sunburst, "win_width", winWidth, 0) ;
	rb_define_module_function(sunburst, "ps_stat", ps_stat, 1) ;

	rb_define_module_function(sunburst, "total_ram", totalRAM, 0) ;
}
