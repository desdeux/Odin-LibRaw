package main

import "libraw"
import "core:fmt"
import "core:os"
import "core:time"
import "core:unicode/utf8"
import "core:strings"

handle_errors :: proc(err: i32) {
    if err != 0 {
        fmt.printf("ERROR: %v\n", libraw.strerror(err));        
    }
}

string_from_slice :: proc(arr: $T) -> string {
    for chr, index in arr {
        if chr == 0 {
            return string(arr[:index]);
        }
    }
    
    return string(arr[:]);
}

main :: proc() {
    my_progress_handler :: proc "contextless" (data: rawptr, stage: libraw.LibRaw_progress, iteration, expected: i32) -> i32 {
        fmt.printf("%v: %v%%\n", libraw.strprogress(stage), (iteration * 100) / expected);
        return 0;
    };
    fmt.printf("ARGS %s", os.args[0]);
    iprc := libraw.init(0);
    defer libraw.close(iprc);
    version := libraw.version();
    versionNumber := libraw.version_number();
    cameras := libraw.camera_count();
    camerasList := libraw.camera_list();
    error := libraw.strerror(-2);
    progress := libraw.strprogress(libraw.LibRaw_progress.LIBRAW_PROGRESS_LOAD_RAW);
    capabilities := libraw.capabilities();
    
    for camera, index in camerasList {
        fmt.printf("%v: %v\n", index + 1, camera);
    }
    fmt.printf("Libraw version: %v\n", version);
    fmt.printf("Libraw version number: %v\n", versionNumber);
    fmt.printf("Number of supported cameras: %v\n", cameras);
    fmt.printf("Error: %v\n", error);
    fmt.printf("Progress: %v\n", progress);
    fmt.printf("Capabilities: %v\n", capabilities);
    libraw.set_progress_handler(iprc, my_progress_handler, nil);
    if len(os.args) > 1 {
        filename := strings.clone_to_cstring(os.args[1]);
        err := libraw.open_file(iprc, filename);
        handle_errors(err);
        if err == 0 {
            fmt.printf("Raw size: %vx%v\n", libraw.get_raw_width(iprc), libraw.get_raw_height(iprc));
            fmt.printf("Actual size: %vx%v\n", libraw.get_iwidth(iprc), libraw.get_iheight(iprc));

            fmt.printf("Processing %v (%s %s)\n", filename, string_from_slice(iprc^.idata.make[:]), string_from_slice(iprc^.idata.model[:]));

            err = libraw.unpack(iprc);
            handle_errors(err);

            err = libraw.dcraw_process(iprc);
            handle_errors(err);

            fmt.printf("Writing to %v\n", "outfn.ppm");

            err = libraw.dcraw_ppm_tiff_writer(iprc, "outfn.ppm");
            handle_errors(err);
        }
    }    
}