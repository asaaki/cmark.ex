# Windows compilation (Win10 64bit)

_Some of the maintainers/contributors have tested it, but only with a Windows 10 64 bit version._
_If you have a different version or architecture you might be out of luck._

## Note for PowerShell usage

You probably will need to run this unless you have already changed this due to other software on your computer:
`Set-ExecutionPolicy -Scope CurrentUser -Policy RemoteSigned`

References:
- https://www.netiq.com/documentation/appmanager-modules/appmanagerforwindows/data/b116b7hm.html
- https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7

If you're a [chocolatey](https://chocolatey.org/) user you most likely have done this already and can go ahead.

## Elixir installation

Follow the instructions from the official Elixir documentation:
https://elixir-lang.org/install.html#windows

I haven't encountered anything tricky here, really nice installer based routine.

## Visual C++ BuildTools

Download the installer and run it:
https://visualstudio.microsoft.com/de/visual-cpp-build-tools/

You can also choose to insall a full Visual Studio environment instead if you plan to do more Windows development,
then you need to search for the build tools in the installer, as VS does not automatically tick it depending on your desired configuration.

You will need to switch to the individual components tab and search for `clang`
(or Visual Studio Community edition if you really want the whole package, but it's not needed)

_I have not succeeded with MSVC's compiler (`cl`) and also do not understand the flags well enough. So only clang (llvm) support for now._

### %PATH% adjustments for your environment variables

Very tricky topic, but you need to figure out the full path to the `clang` bin folder (llvm version) and add it to your `%PATH%` environment variables configuration.

Open a fresh PowerShell after this change.

You can verify this by running `$env:path` in the shell, it should have the path to clang included.

References:
- https://developercommunity.visualstudio.com/idea/875419/how-to-use-msvc-installed-c-clang-tools-for-window.html

## Compile this project

In a powershell, switch to the project. Yes, switch first before doing the next line,
for unknown reasons I couldn't switch drives once I called the vcvarsall.bat file.

Most likely you want to run this:
```shell
cmd /K "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
```

It is very important to use **`amd64`**, no other configuration seems to work. 

Afterwards a valiantly typed `mix do deps.get, compile` should hopefully result in a great success.

Try to open a shell with `iex -S mix` and run `Cmark.to_html("It works!")` — ideally no errors show up.

### `Unspecified error`

This should be a clear indicator that the DLL (or even the `.o` files) was compiled for the wrong target (x86 instead of x64).

https://github.com/erlang/otp/blob/d6285b0a347b9489ce939511ee9a979acd868f71/erts/emulator/sys/win32/erl_win32_sys_ddll.c#L201-L234

The error message could be better, but this is probably the only hint you will get when trying to load the NIF in a iex shell or in your application.

### Build artifacts leftovers and lots of hours

When you did a compilation run and it failed, don't forget to clean the `c_src/*.o` files and the `priv` folder as well.
Otherwise make will skip rebuilding some files and this could lead to unnecessarily spent hours.

_I ran into issues with my shell and permissions and nmake and … so I had an explorer open and deleted such files by hand._

### NMake

Don't run `make` without arguments, it will try to use the (non-windows) Makefile which is incompatible with NMake.

Specify the desired file like this:  `make /F Makefile.win <...>`.
`mix compile` will automatically do that for you (with the great help of `elixir_make`).

### Past experience and support

For historical reference you can read the comments at https://github.com/asaaki/cmark.ex/pull/47 and see if anything else can help.

While only being a fun exercise don't hesitate to [open an issue](hhttps://github.com/asaaki/cmark.ex/issues/new?title=Windows+compilation) 
and we can work together to make it work for you if possible.
