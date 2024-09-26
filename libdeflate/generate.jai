#run build();

build :: () {
    set_build_options_dc(.{do_output=false});

	options := get_build_options();

    src_files := file_list(".");

    headers: [..] string;

    for file: src_files {
        if ends_with(file, ".h") {
            array_add(*headers, file);
        }
    }

    generate_bindings(headers);
}

generate_bindings :: (headers: [] string) -> bool {
    output_filename: string = "lib.jai";
    opts: Generate_Bindings_Options;
    {
        using opts;

        array_add(*libpaths,      ".");
        array_add(*libnames,      "libdeflate");
        array_add(*source_files, ..headers);
        array_add(*extra_clang_arguments, "-x", "c", "-DWIN32_LEAN_AND_MEAN");

        // strip_flags &= ~(Strip_Flags.CONSTRUCTORS | .DESTRUCTORS);
    }

    return generate_bindings(opts, output_filename);
}

#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
#import "File_Utilities";
#import "String";
