{lib, ...}: rec {
  ## Known SSH host keys
  knownHosts = {
    ## unRAID
    "10.0.0.10" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHphh6FhB7vSYn4s04wY5UE9GvfCprZfzbb2D5XEB2RE";
    };

    ## crate-desktop system key
    "10.0.1.19" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQg2lXOJPjxn5tVURFT4MG6k8+zYQdwE5nG/WSvrcKb";
    };

    ## crate-laptop system key
    "10.0.1.36" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1VD8AXVl+oVHO0Ig9++mGcfmY1O+4u+YKgrCGXElpU";
    };

    ## crate-mini system key
    "10.0.0.230" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6zrLr4m6/Uovss4MhtYoGqQ5YUVkyCvj2XkHneNLnE";
    };

    "github.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    "188.245.105.110" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPkE6q8ur78T/YuTnfzlaeZaCqpy5pjouEi5xgG2xxJS";
    };

    "10.0.0.147" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrYsevPxlLuSMXFNgkGCdY3n2ggheQWMVYBGhv9eZ5n";
    };

    "192.168.2.11" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFbBhBuedxH6RM9gosUgeAFrAeL2aBITQojUNkyJwSe";
    };

    "37.27.247.138" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDb/rHEX10Fsur+aWIOuqHZsXIX58enWBe1EYthsw/6j";
    };

    "116.203.101.139" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmEAf1/N984qPc128/CMSU6WTf5PkIqhYdrHgc2K8go";
    };

    "206.217.138.222" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTr8FcbTpt+EoyYQxGI4/T0focbzdPk4Gd08z84UeMV";
    };
  };

  ## Authorized SSH keys for users
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItETI5nQ1tNxHQ7S7dpDodTU1aT6cPe66+jeS3el9Ac matt@crate-laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa4SXR5EFOR97AO858EdPgic2kjFo1i+MSdOzMtj741 matt@crate-desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8vMXPYIfCDqBC4b/phOucgNKeou8XmRjtFhr+W2/oO matt@crate-mini"
  ];
}
