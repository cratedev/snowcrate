final: prev: {
  zellij-plugins = {
    zjstatus = prev.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
      hash = "sha256-TeSCbSCx7+YScp6S6utknZLBf/Lrtdv50XO38BVN3TM=";
    };

    zellij-forgot = prev.fetchurl {
      url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.0/zellij_forgot.wasm";
      hash = "sha256-KbwZ1ah0tdGXWlgWBEpvSd2vqxIduN4nTn4WCucOh1M=";
    };

    zellij-datetime = prev.fetchurl {
      url = "https://github.com/h1romas4/zellij-datetime/releases/download/v0.20.0/zellij-datetime.wasm";
      hash = "sha256-757c8d30f32359d64f61d21a9fd508c65b49aa737b5140c0384f3906183d1993";
    };
  };
}
