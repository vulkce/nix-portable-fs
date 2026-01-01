## About

#### A setup designed for automatic installation

Based on what is defined in [`definition.nix`](general-configs/filesystems/definition.nix), the configuration is automatically built with the correct disk and filesystem options.  
The [`Bash script`](bash_script) acts as a helper tool to format disks and install the system.

The [`definition.nix`](general-configs/filesystems/definition.nix) file is immutable within the repository—only bug fixes are allowed. It is modified only at installation time.

> [!NOTE]
> The [Bash script](bash_script) is still partially experimental, but it is evolving toward handling the entire installation process on its own.
