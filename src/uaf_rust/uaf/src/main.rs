#![allow(dead_code, mutable_transmutes, non_camel_case_types, non_snake_case,
  non_upper_case_globals, unused_assignments, unused_mut)]
#![register_tool(c2rust)]
#![feature(main, register_tool)]
#![feature(new_uninit)]

extern "C" {
#[no_mangle]
fn printf(_: *const libc::c_char, _: ...) -> libc::c_int;
}

#[no_mangle]
fn free_box<T>(t: Box<T>){  
}

#[repr(C)]
pub struct A {
pub fnptr: Option<unsafe extern "C" fn(_: *mut libc::c_char) -> ()>,
pub buf: *mut libc::c_char,
}

#[repr(C)]
pub struct B {
pub B1: i64,
pub B2: i64,
}

pub unsafe extern "C" fn vuln() {
printf(b"In vuln function!\n\x00" as *const u8 as *const libc::c_char);
}

unsafe fn main_0() -> libc::c_int {
  let mut a = Box::<A>::new_uninit().assume_init();
  free_box(a);
  let mut b = Box::<B>::new_uninit().assume_init();
  (*b).B1 = 
    ::std::mem::transmute_copy::<Option<unsafe extern "C" fn() -> ()>,
    i64>(&Some(vuln as
                    unsafe extern "C" fn()
                        -> ()));

  (*a).fnptr.expect("non-null function pointer")((*a).buf);

  return 0 as libc::c_int;
}

#[main]
pub fn main() { unsafe { ::std::process::exit(main_0() as i32) } }
