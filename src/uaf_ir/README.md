## Get the llvm ir code of uaf.c
Go to directory of uaf_ir, and running the following command
```bash
export LLVM_DIR=<installation/dir/of/llvm>
$LLVM_DIR/bin/clang  -emit-llvm uaf.c -S -fno-discard-value-names -o uaf.ll
```
## Generate dependency policy
We use [anytree](https://anytree.readthedocs.io/en/latest/) as the implementation of the dependency tree. 
To intall it, you should run
``` bash
sudo apt install graphviz
pip install anytree
```
Then, you can simply run the following cammands to generate the dependency tree
```bash
cp uaf.ll uaf.ll.txt
python test.py
```
#### bug
Cannot use DotExporter to store user defined class in the picture... see `[bug]` tag in the test.py.
