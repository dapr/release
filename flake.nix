{
  description = "Dapr release development & testing environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Track the current default Python in nixpkgs-unstable (latest stable).
        python = pkgs.python3;

        commonPackages = with pkgs; [
          ansible
          ansible-lint
          opentofu
          go
          gopls
          gotools
          go-tools
          golangci-lint
          delve
          python
          python.pkgs.pip
          python.pkgs.virtualenv
          python.pkgs.pyyaml
          python.pkgs.requests
          git
          gnumake
          jq
          yq-go
          curl
          kubectl
          kubernetes-helm
          k9s
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "dapr-release";

          packages = commonPackages;

          shellHook = ''
            echo "dapr_release dev shell"
            echo "  ansible   $(ansible --version | head -n1)"
            echo "  python    $(python --version)"
            echo "  go        $(go version)"
            echo "  tofu      $(tofu version | head -n1)"
            echo "  kubectl   $(kubectl version --client=true -o yaml 2>/dev/null | awk '/gitVersion/ {print $2; exit}')"
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
