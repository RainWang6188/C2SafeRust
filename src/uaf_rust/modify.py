def rewrite_malloc(code):
    Name = code[code.find("let mut") + 8 : code.find(":")]
    Type = code[code.find(":") + 7 : code.find("=") - 1]
    return "\tlet mut " + Name + " = Box::<" + Type + ">::new_uninit().assume_init();\n"


def rewrite_free(code):
    index = code.find("free(")
    Name = code[index + 5 : code.find(" ", index)]
    return "\tfree_box(" + Name + ");\n"


ORG_FILE_NAME = "uaf_org.rs"
MOD_FILE_NAME = "uaf_safe.rs"
org_rs = open(ORG_FILE_NAME, "r")
mod_rs = open(MOD_FILE_NAME, "w")

org_code = []

for line in org_rs:
    org_code.append(line.replace("libc::c_int", "i64"))

line, total = 0, len(org_code)

# step-1 delete malloc & free function
while(1):
    code = org_code[line]
    line = line + 1
    if code.startswith('extern "C"'):
        mod_rs.write("#![feature(new_uninit)]\n")
        mod_rs.write(code)
        break
    mod_rs.write(code)

while(1):
    code1 = org_code[line]
    line = line + 1
    if code1.find("#[no_mangle]") != -1:
        code2 = org_code[line]
        line = line + 1
        if code2.find("fn malloc(_: libc::c_uint) -> *mut libc::c_void;") != -1:
            continue
        elif code2.find("fn free(__ptr: *mut libc::c_void);") != -1:
            continue
        else:
            mod_rs.write(code1)
            mod_rs.write(code2)
    else:   # }
        mod_rs.write(code1)
        break

mod_rs.write("#[no_mangle]\nfn free_box<T>(t: Box<T>){ }")

# step-2 modify use of malloc & free in main_0 function
main_func = ""

while(1):
    code = org_code[line]
    line = line + 1
    mod_rs.write(code)
    if code.find("unsafe fn main_0() -> i64 {\n") != -1:
        while(1):
            code = org_code[line]
            line = line + 1
            main_func += code
            if code.endswith("return 0 as i64;\n"):
                break
        break

main_code = main_func.split(";")

for code in main_code[:-1]:
    # replace malloc with Box
    if code.find("malloc") != -1:
        mod_rs.write(rewrite_malloc(code))
    # replace with new free function
    elif code.find("free") != -1:
        mod_rs.write(rewrite_free(code))
    else:
        mod_rs.write(code + ";")
mod_rs.write(main_code[-1])

while(line < total):
    code = org_code[line]
    line = line + 1
    mod_rs.write(code)

org_rs.close()
mod_rs.close()