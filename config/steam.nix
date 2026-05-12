# steam.nix
#
# Drop-in NixOS module for running Trackmania 2020 (and Windows games in
# general) via Steam + Proton. Tested target: NixOS 25.11 / unstable, x86_64.
#
# Adapts to the host:
#   - Common: NTSync, Steam + GE-Proton, GameMode, Gamescope, 32-bit GL,
#     protontricks, MangoHud, sensible ulimits / shader cache env.
#   - Intel Alder Lake iGPU (both kotn + flipsy): blacklist `xe`, force `i915`,
#     enable GuC submission, install `intel-media-driver` + `vpl-gpu-rt`.
#   - Nvidia (kotn only, gated by `custom.hardware.enableNvidia`): add
#     `nvidia-vaapi-driver`, configure GameMode `[gpu]` for the dGPU.
#
# Enable per-host with:
#   custom.gaming.enable = true;
#
# After rebooting, verify:
#   uname -r                  # mainline kernel with ntsync as a module
#   ls -l /dev/ntsync         # should exist, mode crw-rw-rw-
#   lsmod | grep ntsync       # should show the module loaded
#
# Then in Steam:
#   Settings -> Compatibility -> Enable Steam Play for all other titles
#   Set "Run other titles with" to GE-Proton (latest), or per-game via
#   right-click -> Properties -> Compatibility.
#
# On kotn (PRIME offload), launch games via Steam launch options:
#   nvidia-offload gamemoderun %command%
# Driver, PRIME offload, `nvidia-offload` command, Ampere `open` driver, and
# bus IDs are all set by nixos-hardware's `asus-zephyrus-gu603h` module —
# see flake.nix. The local config/nvidia.nix is unused / superseded.
#
# Black main-library window workaround (Niri/XWayland + Mesa Intel):
#   Settings -> Interface -> turn OFF "GPU Accelerated Rendering in Web Views".
#   Symptom: login/chat/popups paint, only the CEF main view is black. Cause
#   is Chromium GPU compositing failing under XWayland; the toggle keeps
#   hardware GL for games and only disables it for the Steam UI. Persists
#   in ~/.local/share/Steam/, so this only matters on a fresh Steam config.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.gaming;
  nvidia = config.custom.hardware.enableNvidia;
in
{
  # Option declared in config/hardware.nix alongside the other custom.* opts
  # so it's also mirrored into home-manager's shared module scope.
  config = lib.mkIf cfg.enable (lib.mkMerge [

    ###########################################################################
    # Common: kernel module, Steam, GameMode, Gamescope, packages, env, limits
    ###########################################################################
    {
      # NTSync replaces esync/fsync in Wine/Proton with kernel-level Windows
      # synchronization primitives — large stability and perf win for games.
      # Stock mainline kernel 6.10+ ships it as a module (CONFIG_NTSYNC=m), so
      # we just need to load it.
      boot.kernelModules = [ "ntsync" ];

      # `nixpkgs.config.allowUnfree = true` is already set globally in
      # config/nix.nix, which covers steam, steam-unwrapped, proton-ge-bin,
      # nvidia-x11, etc. No per-package predicate needed here.

      hardware.graphics = {
        enable = true;
        enable32Bit = true; # 32-bit GL/Vulkan for Steam runtime
      };

      # Udev rules for Steam Controller, Steam Deck controllers, Steam Link,
      # and DualShock/DualSense pads. `programs.steam.enable` does NOT pull
      # these in automatically.
      hardware.steam-hardware.enable = true;

      programs.steam = {
        enable = true;

        # Open ports for Remote Play (harmless if you don't use it).
        remotePlay.openFirewall = true;

        # Declaratively make GE-Proton available in Steam's compatibility tool
        # dropdown. No need for ProtonUp-Qt unless you want a GUI to swap
        # specific GE versions.
        extraCompatPackages = [ pkgs.proton-ge-bin ];

        # Workaround for nixpkgs#389142: Steam runs games inside an FHS sandbox
        # and won't see libgamemode.so unless we inject it into the wrapper.
        package = pkgs.steam.override {
          extraPkgs =
            pkgs: with pkgs; [
              gamemode
              # Some games / launchers also pull these in:
              keyutils
              libkrb5
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              libxcursor
              libxi
              libxinerama
              libxscrnsaver
            ];
        };
      };

      # Use it via Steam launch options: gamemoderun %command%
      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings.general = {
          renice = 10;
          inhibit_screensaver = 1;
        };
      };

      # Use via Steam launch options, e.g.:
      #   gamemoderun gamescope -W 1920 -H 1080 -r 144 -f -- %command%
      # The -F fsr flag enables AMD FSR upscaling, useful on iGPUs:
      #   gamescope -W 1920 -H 1080 -F fsr -w 1280 -h 720 -- %command%
      programs.gamescope = {
        enable = true;
        capSysNice = false; # avoid conflict with gamemode renicing
      };

      environment.systemPackages = with pkgs; [
        mangohud # FPS / frametime / temp overlay (MANGOHUD=1 %command%)
        protontricks # Required for Openplanet install + per-prefix tweaks
        protonup-qt # Optional GUI for managing extra GE-Proton versions
        winetricks # Useful when poking around prefixes manually
        vulkan-tools # `vulkaninfo | head -n 30` for sanity checks
      ];

      environment.sessionVariables = {
        # Persistent shader caches across runs (Mesa)
        MESA_SHADER_CACHE_DIR = "$HOME/.cache/mesa_shader_cache";
        # Larger DXVK shader cache
        DXVK_STATE_CACHE_PATH = "$HOME/.cache/dxvk";
      };

      # Some games rely on more file descriptors than the default soft limit.
      systemd.settings.Manager.DefaultLimitNOFILE = 1048576;
      security.pam.loginLimits = [
        {
          domain = "*";
          type = "soft";
          item = "nofile";
          value = "524288";
        }
        {
          domain = "*";
          type = "hard";
          item = "nofile";
          value = "1048576";
        }
      ];
    }

    ###########################################################################
    # Intel Alder Lake iGPU (both hosts have one)
    ###########################################################################
    # `i915` (legacy, stable) and `xe` (new, still maturing) both autoload on
    # Alder Lake (Iris Xe, e.g. PCI 8086:46A6 / 46A8). They fight over the
    # same device and the conflict manifests as `i915 GPU HANG` under heavy
    # DXVK workloads. For Alder Lake in 2026, i915 is the stable choice —
    # keep it and prevent xe from binding.
    {
      boot.blacklistedKernelModules = [ "xe" ];
      boot.kernelParams = [
        "xe.force_probe=!46a6" # tell xe to NOT bind this device
        "i915.enable_guc=3" # enable GuC submission + HuC firmware load
      ];
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver # VA-API (iHD) userspace
        vpl-gpu-rt # oneVPL (QSV) runtime
      ];
    }

    ###########################################################################
    # Nvidia dGPU add-on (kotn: RTX 3060)
    ###########################################################################
    # Driver, PRIME offload, and `nvidia-offload` command come from
    # nixos-hardware's asus-zephyrus-gu603h module. This block only adds the
    # gaming-specific bits on top.
    (lib.mkIf nvidia {
      hardware.graphics.extraPackages = with pkgs; [
        nvidia-vaapi-driver # NVDEC-backed VA-API (Firefox/mpv on dGPU)
      ];

      # GameMode optimisations for the nvidia card. `accept-responsibility`
      # is the upstream-required opt-in that acknowledges these knobs may
      # crash the driver. `nv_powermizer_mode = 1` forces "Prefer Maximum
      # Performance" while a game is running.
      # `gpu_device` is gamemode's index into the GPUs it enumerates; on
      # Optimus laptops the intel/nvidia order depends on probe timing.
      # Verify on kotn with `gamemoded -t` (the dGPU's vendor/device IDs
      # should match `lspci -nn -d 10de:`) and flip to 1 if needed.
      programs.gamemode.settings.gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
      };
    })

  ]);
}
