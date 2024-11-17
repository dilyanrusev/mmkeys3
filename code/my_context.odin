package main

import "base:runtime"
import "core:log"
import "core:strings"
import "core:fmt"
import w "core:sys/windows"

output_debug_logger_proc :: proc(
	data: rawptr,
	level: runtime.Logger_Level,
	text: string,
	options: runtime.Logger_Options,
	location := #caller_location,
) {
    backing: [1024]byte //NOTE(Hoej): 1024 might be too much for a header backing, unless somebody has really long paths.
    buf := strings.builder_from_bytes(backing[:])

    log.do_level_header(options, &buf, level)

    // when time.IS_SUPPORTED {
    //     do_time_header(options, &buf, time.now())
    // }

    log.do_location_header(options, &buf, location)

    // if .Thread_Id in options {
    //     // NOTE(Oskar): not using context.thread_id here since that could be
    //     // incorrect when replacing context for a thread.
    //     fmt.sbprintf(&buf, "[{}] ", os.current_thread_id())
    // }

    // if data.ident != "" {
    //     fmt.sbprintf(&buf, "[%s] ", data.ident)
    // }

    fmt.sbprintf(&buf, "%s\r\n ", text)

    //TODO(Hoej): When we have better atomics and such, make this thread-safe
    w.OutputDebugStringA(cstring(raw_data(backing[:])))
}

create_output_debug_logger :: proc() -> runtime.Logger {
	l: runtime.Logger
	l.lowest_level = .Debug
	l.options = {.Short_File_Path, .Procedure, .Line}
	l.procedure = output_debug_logger_proc
	return l
}

create_my_context :: proc() -> runtime.Context {
	ctx := runtime.default_context()
	ctx.logger = create_output_debug_logger()
	return ctx
}
