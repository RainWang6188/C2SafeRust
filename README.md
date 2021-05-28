# C2SafeRust-semiAutomated-Tool
An semi-automated auxiliary tool which helps to translate C to safe Rust.
We aim to demonstrate that those vulnerabilities in C will no longer exist when we translate it to safe Rust. So we choose to use a simple [UAF](https://ctf-wiki.org/pwn/linux/glibc-heap/use_after_free/) demo to show the complete process. 

## File Structure
```
C2SafeRust
├───── src
│      ├─── uaf_c
|      |      ├─── build (after running build.sh)
|      |      |      ├─── compile_commands.json
|      |      |      ├─── uaf
|      |      |      └─── ...
|      |      |
│      |      ├─── CMakeLists.txt
│      |      ├─── uaf.c
│      |      └─── build.sh
│      |
│      ├─── uaf_rust
|      |        ├─── uaf (after running cargo new)
|      |        |      ├─── Cargo.toml
|      |        |      └─── src
|      |        |            └─── main.rs
|      |        |
│      |        └─── uaf_origin.rs
│      |
|      |
|      └──── uaf_ir
|              ├─── uaf.ll
│              └─── uaf.c
|
├─── report
|       ├─── template
|       └─── ... 
|
└───── README.md
```

## Translate uaf.c to uaf.rs
Go to the directory `./src/uaf_c` and run the build.sh via bash
``` bash
cd ./src/uaf_c && bash build.sh
```
`build.sh` involves two steps:
1. generate `compile_commands.json` and `uaf` executable in the build directory
2. generate `uaf.rs` in the parenet directory of build using the [c2rust](https://github.com/immunant/c2rust) tool.
After building the project, you can clean it using
```bash
rm -rf build uaf.rs
```

## Build cargo project of uaf
First, we need to change the dir to uaf_rust, and generate a new cargo project `uaf`
``` bash
cd ./src/uaf_rust && cargo new uaf
```
Then, we need to add libc to the library dependency in the ./uar/Cargo.toml, as follows:
``` 
[dependencies]
libc = "0.2"
```
Next, we can replace the `main.rs` in the rust project with the `uaf.rs` generated previously (or simply use the `uaf_org.rs`, they're the same). Note that when you run `cargo +nightly build` command with the original file, you wil get several errors. Those errors can be solved by making following modification to the `main.rs`
1. Change the `as libc::c_ulong` in those `malloc` function to `as u32`. So the result for A's malloc would be
    ```rust
    let mut a: *mut A =
            malloc(::std::mem::size_of::<A>() as libc::c_ulong) as *mut A;
    ```
2. Change the sentence:
    ```rust
    (*b).B1 =
    ::std::mem::transmute::<Option<unsafe extern "C" fn() -> ()>,
                            libc::c_int>(Some(vuln as
                                                    unsafe extern "C" fn()
                                                        -> ()));
    ```
    into the following:
    ```rust
    (*b).B1 =
    ::std::mem::transmute_copy::<Option<unsafe extern "C" fn() -> ()>,
                            libc::c_int>(&Some(vuln as
                                                    unsafe extern "C" fn()
                                                        -> ()));
    ```
Then, it can successfully pass the `cargo +nightly build`. 
#### Note
But you will get `Segmentation fault` when running this project. I think the reason is that the size of `Option<T>` is 8, but `libc::c_int` is 4... So we need to set B1 and B2 to `i64`. The `uaf_mod.rs` file under the `src/uaf_rust` directory is the modification result. 
```rust
Size of struct A: 16
Size of Option<fnptr>: 8
Size of *mut libc::c_char: 8

Size of struct B: 8
Size of libc::c_int: 4
Size of i64: 8
```

## Get the llvm ir code of uaf.c
Go to director of uaf_ir, and running the following command
```bash
export LLVM_DIR=<installation/dir/of/llvm/12>
$LLVM_DIR/bin/clang  -emit-llvm uaf.c -S -g -fno-discard-value-names -o uaf.ll
```

