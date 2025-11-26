{ config, lib, pkgs, ... }: {
  
  # montar meus hds automaticamente
  fileSystems."/home/vulkce/Documents/etc1" = {
    device = "/dev/disk/by-uuid/2896792c-503e-4e52-bbd6-05fc5ae67675";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
 };

  fileSystems."/home/vulkce/Documents/HD1" = {
    device = "/dev/disk/by-uuid/2a01b06c-f29d-4375-9c18-f5d3733df8e7";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
 };

  fileSystems."/home/vulkce/Documents/HD2" = {
    device = "/dev/disk/by-uuid/1b8e11e0-d2f3-4d74-833a-1a1aca422b89";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
 };

  fileSystems."/home/vulkce/Documents/etc2" = {
    device = "/dev/disk/by-uuid/d47d9f1f-c57e-41b9-95cd-48f75d0500c8";
    fsType = "btrfs";
    options = [ "users" "exec" "nofail" ];
 };
  
}
