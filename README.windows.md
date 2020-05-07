# Windows compilation (Win10 64bit)

Install Elixir on Windows:
https://elixir-lang.org/install.html#windows

Install Visual C++ BuildTools:
https://visualstudio.microsoft.com/de/visual-cpp-build-tools/
(or Visual Studio Community edition if you really want the whole package, but it's not needed)

In the installer search for the `clang` in the individual components tab (the llvm version alone should be enough).

_I have not succeeded with MSVC's compiler (`cl`) and also do not understand the flags well enough. So only clang support for now._

In a powershell, switch to the project. Yes, switch first before doing the next line,
for unknown reasons I couldn't switch drives once I called the vcvarsall.bat file.

Most likely you want to run this:
```shell
cmd /K "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" amd64
```
(unless you have already adjusted PATH and other env vars; but I guess it will also set other useful variables I'm not aware of.)

### `Unspecified error`

This should be a clear indicator that the DLL (or even the `.o` files) was compiled for the wrong target (x86 instead of x64).

https://github.com/erlang/otp/blob/d6285b0a347b9489ce939511ee9a979acd868f71/erts/emulator/sys/win32/erl_win32_sys_ddll.c#L201-L234

The error message could be better, but this is probably the only hint you will get when trying to load the NIF in a iex shell or in your application.
