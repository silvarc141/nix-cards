{
  lib,
  runCommand,
  ruby-squib-env,
  ...
}: {
  cardTypes,
  graphicsDirectory,
  csvDirectory,
  rubySourceDirectory,
  extraPackages ? [],
  fontDirectories ? [],
  variants ? [
    "pdf"
    "pdf-pnp"
    "sheet"
    "sheet-pnp"
    "images"
    "images-pnp"
    "single"
  ],
}: let
  inherit (lib) getExe concatLines;
  inherit (builtins) listToAttrs concatMap;
  ruby = getExe (ruby-squib-env.override { 
    inherit fontDirectories extraPackages;
  });

  mkRunLine = variant: cardType: side: ''
    ${ruby} \
      '${rubySourceDirectory + "/init.rb"}' \
      "$out" \
      '${graphicsDirectory}' \
      '${graphicsDirectory}/${cardType}-${side}' \
      '${variant}' \
      '${cardType}' \
      '${side}' \
      '${rubySourceDirectory}' \
      '${csvDirectory}/${cardType}.csv'
  '';

  init = 
    #ruby
    ''
      $output_dir, 
      $graphics_path, 
      $specific_graphics_path, 
      $csv_path,
      src_path, 

      $output_variant, 
      $card_type, 
      $card_side, 

      $LOAD_PATH.unshift(src_path)

      script_name = "#{$card_type}-#{$card_side}.rb"
      puts "-> Initializing deck generation for: #{script_name}"
      target_script_file = File.join(src_path, "#{script_name}")

      if File.exist?(target_script_file)
        require target_script_file
      else
        puts "Error: Target script not found at '#{target_script_file}'"
        exit 1
      end

      puts "-> Finished deck generation for: #{script_name}"
    '';

  mkRunCommand = name: cardTypes: sides: variant:
    runCommand name {} ''
      mkdir -p $out
      ${concatLines (map (
          cardType: (concatLines (map (mkRunLine variant cardType) sides))
        )
        cardTypes)}
    '';

  baseName = baseNameOf rubySourceDirectory;
  sides = [ "front" "back" ];
  allSides = sides ++ ["both"];

  expandSide = side:
    if side == "both"
    then sides
    else [side];

  packagesMetaAll = listToAttrs (
    concatMap (
      side:
        map (variant: let
          name = "${baseName}-all-${side}-${variant}";
        in {
          inherit name;
          value = mkRunCommand name cardTypes (expandSide side) variant;
        })
        variants
    )
    allSides
  );

  packages = listToAttrs (
    concatMap (
      cardType:
        concatMap (
          side:
            map (variant: let
              name = "${baseName}-${cardType}-${side}-${variant}";
            in {
              inherit name;
              value = mkRunCommand name [cardType] (expandSide side) variant;
            })
            variants
        )
        allSides
    )
    cardTypes
  );
in
  packages // packagesMetaAll
