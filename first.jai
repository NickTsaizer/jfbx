#import "File";
#import "Basic";

#load "libdeflate/lib.jai";

FBX :: struct {

    Node_Info :: struct {
        next: u32;
        prop_count: u32;
        prop_size: u32;
        name_size: u8;
    }

    Node_Type :: enum u8 #specified {
        NONE :: 0;

        S16 :: #char "Y";
        S32 :: #char "I";
        S64 :: #char "L";
        BOOL :: #char "C";
        FLOAT :: #char "F";
        DOUBLE :: #char "D";

        ARRAY_FLOAT32 :: #char "f";
        ARRAY_FLOAT64 :: #char "d";
        ARRAY_S32 :: #char "i";
        ARRAY_S64 :: #char "l";
        ARRAY_BOOL :: #char "b";

        STRING :: #char "S";
        RAW :: #char "R";
    }

    Prop :: struct {
        type: Node_Type = .NONE;
        union {
            as_s16: s16;
            as_s32: s32;
            as_s64: s64;
            as_bool: bool;
            as_float32: float32;
            as_float64: float64;
            
            as_s32_arr: []s32;
            as_s64_arr: []s64;
            as_float32_arr: []float32;
            as_float64_arr: []float64;
            as_bool_arr: []bool;

            as_string: string;
            as_buffer: Buffer;
        }
    }

    Buffer :: struct {
        size: u32;
        value: *void;
    }

    Node :: struct {
        offset: u32 = 0;
        name: string = "";
        props: [..]Prop;
        children: [..]Node;
    }

    Scene :: struct {
        fbx_header_extension: Node;
        file_id: Node;
        creation_time: Node;

    }

    Cursor :: struct {
        begin: *u8 = null;
        current: *u8 = null;
        end: *u8 = null;
    }

    log_node :: (node: Node, deep: s32 = 0) {
        builder : String_Builder;
        for i: 0..deep-1 {
            print_to_builder(*builder, "\t");
        }

        prefix := builder_to_string(*builder);
        
        print("% %:", prefix, node.name);
        

        for prop: node.props {
            if prop.type == {
                case .RAW;      print(" %", prop.as_buffer.value);
                case .STRING;   print(" \"%\"", prop.as_string);
                case .S16;      print(" %", prop.as_s16);
                case .S32;      print(" %", prop.as_s32);
                case .S64;      print(" %", prop.as_s64);
                case .FLOAT;    print(" %", prop.as_float32);
                case .DOUBLE;   print(" %", prop.as_float64);
                case .BOOL;     print(" %", prop.as_bool);
                
                case .ARRAY_BOOL;       log("%    [%]", prefix, prop.as_bool_arr);
                case .ARRAY_FLOAT32;    log("%    [%]", prefix, prop.as_float32_arr);
                case .ARRAY_FLOAT64;    log("%    [%]", prefix, prop.as_float64_arr);
                case .ARRAY_S32;        log("%    [%]", prefix, prop.as_s32_arr);
                case .ARRAY_S64;        log("%    [%]", prefix, prop.as_s64_arr);

                case; {
                    print("%", prop.type);
                }
            }
        }

        print("\n");
        for child: node.children {
            log_node(child, deep+1);
        }
    }

    load :: (filename: string) -> Node {
        file, success := read_entire_file(filename,, temp);

        if !success {
            log("Unable to load file '%'", filename);
        }

        log("Loading FBX:");
        log("\tfile: '%'", filename);
        log("\tversion: %", <<cast(*u32)*file[23]);

        root: Node;
        root.name = "root";

        consume_node(.{file.data, file.data+27, file.data+file.count}, *root);
    
        log_node(root);
        return root;
    }

    read_int :: (buffer: *u8, $RT: Type) -> RT {

        #insert -> string {
            body_builder: String_Builder;
            len := size_of(RT);
            print_to_builder(*body_builder, "result := (cast(%)(buffer[0]))", RT);
            for index: 1..len-1 {
                print_to_builder(*body_builder, " | (cast(%)(buffer[%]) << %)", RT, index, index*8);
            }

            print_to_builder(*body_builder, ";");

            return builder_to_string(*body_builder);
        }

        return result;
    }

    decompress :: (in: *u8, in_size: u64, out: *u8, out_size: u64) -> libdeflate_result
    {
        dec := libdeflate_alloc_decompressor();
        dummy: u64;
        res: = libdeflate_deflate_decompress(dec, in + 2, in_size - 2, out, out_size, *dummy);
        libdeflate_free_decompressor(dec);
        return res;
    }

    read_array :: (in_ptr: *u8, $RT: Type) -> []RT, u32 {
        
        ptr := in_ptr;

        array_length        := read_int(ptr, u32);
        encoding            := read_int(ptr + size_of(u32), u32);
        encoded_size   := read_int(ptr + size_of(u32) * 2, u32);

        ptr += size_of(u32) * 3;
        log("res_len: %", array_length);
        log("encoding: %", encoding);
        log("encoded_size: %", encoded_size);
        

        result := NewArray(array_length, RT);

        if(encoding == 1) {

            res: = decompress(ptr, encoded_size, cast(*u8)result.data, xx(size_of(RT) * result.count));
            log("%", res);
        }

        return result, encoded_size + size_of(u32) * 3;
    }

    consume_node :: (cursor: Cursor, parent: *Node) {
        offset := cast(u32)(cursor.current-cursor.begin);

        for sibling: parent.children {
            if sibling.offset == offset then return;
        }
        
        n_info := cast(*Node_Info)cursor.current;
        
        if n_info.name_size<=0 return;

        node: *Node = array_add(*parent.children);
        node.offset = offset;
        node.name = to_string(cursor.current+13, n_info.name_size);

        ptr := cursor.current+13+n_info.name_size;
        type := <<cast(*Node_Type)(ptr);
        ptr += 1;
        
        if n_info.prop_count>0 then for p_index: 0..n_info.prop_count-1 {
            prop := array_add(*node.props);
            prop.type = type;

            if type == {
                case .RAW; {
                    len := read_int(ptr, u32);
                    ptr += 4;
                    prop.as_buffer.size = len;
                    prop.as_buffer.value = alloc(len);
                    memcpy(prop.as_buffer.value, ptr, len);
                    ptr += len; 
                }
                case .STRING; {
                    len := read_int(ptr, u32);
                    ptr += 4;
                    prop.as_string = to_string(ptr, len);
                    ptr += len;
                }

                case .S16; {
                    prop.as_s16 = read_int(ptr, s16);
                    ptr += 2;
                }

                case .S32; {
                    prop.as_s32 = read_int(ptr, s32);
                    ptr += 4;
                }

                case .S64; {
                    prop.as_s64 = read_int(ptr, s64);
                    ptr += 8;
                }

                case .FLOAT; {
                    memcpy(*prop.as_float32, ptr, 4);
                    ptr += 4;
                }

                case .DOUBLE; {
                    memcpy(*prop.as_float64, ptr, 8);
                    ptr += 8;
                }
                

                case .BOOL; {
                    prop.as_bool = <<ptr>0;
                    ptr += 1;
                }

                case .ARRAY_FLOAT64; {
                    while (ptr[12] == 120 && ptr[13] == 1) {
                        array, consumed := read_array(ptr, float64);
                        ptr += consumed;
                    }
                }

                case .ARRAY_FLOAT32; {
                    while (ptr[12] == 120 && ptr[13] == 1) {
                        array, consumed := read_array(ptr, float32);
                        ptr += consumed;
                    }
                }

                case .ARRAY_S64; {
                    while (ptr[12] == 120 && ptr[13] == 1) {
                        array, consumed := read_array(ptr, s64);
                        ptr += consumed;
                    }
                }

                case .ARRAY_S32; {
                    while (ptr[12] == 120 && ptr[13] == 1) {
                        array, consumed := read_array(ptr, s32);
                        ptr += consumed;
                    }
                }

                case .ARRAY_BOOL; {
                    while (ptr[12] == 120 && ptr[13] == 1) {
                        array, consumed := read_array(ptr, bool);
                        ptr += consumed;
                    }
                }

                case; {
                    log("\t%", type);
                    break;
                }
            }

            next_type := <<cast(*Node_Type)(ptr);
            if next_type {
                type = next_type;
                ptr += size_of(u8);
            }        
        }

        nextpoint := cursor.current+n_info.name_size+n_info.prop_size+13;
        if nextpoint<cursor.begin+n_info.next {
            consume_node(.{cursor.begin, nextpoint, cursor.begin+n_info.next}, node);
        }

        if n_info.next {
            nextpoint := cursor.begin+n_info.next;
            if nextpoint<cursor.end {
                consume_node(.{cursor.begin, nextpoint, cursor.end}, parent);
            }   
        } 

    }
}