{...}: final: prev: {
  zellij-plugins = {
    zjstatus = prev.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
      hash = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
    };

    zellij-forgot = prev.fetchurl {
      url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.0/zellij_forgot.wasm";
      hash = "sha256-WdPKHrCtmg0dv446f8KkHNnAk/GKXtufJfCZyLXf7cM=";
    };

    zellij-datetime = prev.fetchurl {
      url = "https://github.com/h1romas4/zellij-datetime/releases/download/v0.21.0/zellij-datetime.wasm";
      hash = "sha256-oVMh3LlFe4hcY9XmcEHz8pmodyf1aMvgDH31QEusEEE=";
    };
  };
}
