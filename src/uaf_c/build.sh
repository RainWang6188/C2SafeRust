mkdir build && cd build
# generate compile_commands.json & uaf executable under this directory
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..

# generate uaf.rs using c2rust (uaf.rs can be found in the parent directory)
c2rust transpile ./compile_commands.json


