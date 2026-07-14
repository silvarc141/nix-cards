{
  pkgs,
  pkgsSelf,
  ...
}:
{
  test-ruby-squib-env =
    let
      squib-sample = pkgs.writeText "hello.rb" /* ruby */ ''
        require 'squib'
        Squib::Deck.new cards: 1 do
          background color: 'pink'
          rect
          text str: 'Draw two cards.'
          save_png prefix: 'part1_'
        end
      '';
    in
    pkgs.runCommand "build-squib-sample" { } ''
      ${pkgs.lib.getExe pkgsSelf.ruby-squib-env} ${squib-sample}
      [ -d _output ] || (echo "Error: _output directory not found"; exit 1)
      cp -r _output $out
    '';
  test-mk-vtt-game =
    let
      gameName = "testGame";
      images = pkgs.runCommand "mock-images" { } ''
        mkdir -p $out
        PNG_DATA_1X1="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-front-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-back-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-front-testCard1.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckA-back-testCard1.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-front-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-back-testCard0.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-front-testCard1.png
        echo $PNG_DATA_1X1 | base64 -d > $out/${gameName}-testDeckB-back-testCard1.png
      '';
    in
    pkgsSelf.mkVttGame { inherit gameName images; };
}
