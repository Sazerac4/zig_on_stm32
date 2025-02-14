# Step by Step installation for windows

## Description

Here an exemple procedure to install evrything needed. It was tested on windows 11.


## Tools

1. Create a `tools` folder (example : `C:\tools` )
2. Download [Zig](https://ziglang.org/builds/zig-windows-x86_64-0.14.0-dev.3213+53216d2f2.zip)
3. Download [Arm GNU Toolchain](https://github.com/xpack-dev-tools/arm-none-eabi-gcc-xpack/releases/tag/v14.2.1-1.1)
4. Download [ST link](https://github.com/stlink-org/stlink/releases/tag/v1.8.0)
5. Download [OpenOCD](https://github.com/xpack-dev-tools/openocd-xpack/releases/tag/v0.12.0-4)
6. Extract everything to the folder `tools`


**ST link**

You will need to copy `C:\tools\stlink-1.8.0-win32\Program Files (x86)\stlink` to `C:\Program Files (x86)\stlink`

**Drivers**

You will need [ST Link](https://www.st.com/en/development-tools/stsw-link009.html) Drivers to communicate with some nucleo board

**Setup environnement variables**

Here, the command to setup environnement variable according to the instructions below.
You need to choice between System wide or User level. Example below work if you use `C:\tools` 

- System wide (admin Powershell):

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\tools\stlink-1.8.0-win32\bin;C:\tools\zig-windows-x86_64-0.14.0-dev.3213+53216d2f2;C:\tools\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin;C:\tools\xpack-openocd-0.12.0-4\bin",
   "Machine"
)
```
- User level (Powershell):

```powershell
[Environment]::SetEnvironmentVariable(
   "Path",
   [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\tools\stlink-1.8.0-win32\bin;C:\tools\zig-windows-x86_64-0.14.0-dev.3213+53216d2f2;C:\tools\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin;C:\tools\xpack-openocd-0.12.0-4\bin",
   "User"
)
```


## Containers (with podman)

You can use Podam on windows. Few steps are required for that
Main tutoriam [Podman for Windows](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md)


**Limitation**

No communication with USB devices. So you can't flash with the device

**Instruction**

1. Activate hyperV 


2. Install WSL

```powershell
wsl --install
```

3. Start podman machine

Download [Podman](https://github.com/containers/podman/releases) and install.

```powershell
podman machine init
podman machine start
````




You can also a GUI [Podman desktop](https://podman-desktop.io/) to visualize your images and containers.