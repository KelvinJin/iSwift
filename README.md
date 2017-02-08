iSwift is the kernel IPython/Notebook implementation for Swift programming language.

It can:
  + Execute swift code on the Jupyter Notebook web editor, Jupyter console as well as Jupyter qtconsole.
  + Autocomplete swift code by pressing tab ↹.
  + Support encryption.

#### Demo

http://jupyter.uthoft.com

#### Usage

Clone this repo locally. And:

1. Build the project.

```
swift build
```

2. Currently, in order to run swift kernel locally, you need to create a file named
`kernel.json`. Put the following content to the file and replace the `Path/to/iSwift`
with your local clone path.

```json
{
 "argv": ["Path/to/iSwift/.build/debug/iSwift", "-f", "{connection_file}"],
 "display_name": "Swift",
 "language": "swift"
}
```

3. Install Jupyter kernel: (replace the `Folder/that/has/kernel/json` with
  the path of the folder that contains the `kernel.json` file)

```
jupyter-kernelspec install Folder/that/has/kernel.json
```

4. Run Jupyter Notebook:
```
jupyter notebook
```

#### Contribution

Contributions are welcome. Simply create an issue if you have ideas on how we
can improve iSwift.

#### License
MIT
