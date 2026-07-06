def createImageAssetData [ imagesDir : string ] {
  ls ($imagesDir | path expand) | each {
    let path = $in.name
    let size = $in.size | into int
    let crc = getSignedCrc $path
    let vttFileName = $"($crc)_($size)"
    let parsed = $path | parse --regex '(?<game>[a-z]*)-(?<deck>[a-z]*)-(?<side>[a-z]*)(?<index>\d*)'
    $parsed 
    | insert path $path
    | insert vttFileName $vttFileName
    | insert vttPath $"/assets/($vttFileName)"
    | reject game
  } | flatten
}

def getSignedCrc [ filePath : string ] {
    let stringCrc = cat $filePath | ^crc32
    let intCrc = ($"0x($stringCrc)" | into int)
    if $intCrc > 0x7fffffff {
      $intCrc - 0x100000000
    } else {
      $intCrc
    }
}

def createCardInstanceVttStructs [ cards: table ] {
  $cards | where side == "front" | each {
    {
      id: $"($in.deck)($in.index)Card",
      type: "card",
      deck: $"($in.deck)Deck",
      cardType: $"($in.deck)($in.index)",
      parent: $"($in.deck)Pile"
    }
  } | reduce -f {} {|row, acc| $acc | insert $row.id $row }
}

def createDeckVttStructs [ cards: table, width: int, height: int ] {
  $cards
  | group-by deck --prune 
  | transpose name cards
  | enumerate
  | flatten
  | each { constructDeck $in.cards $in.name $width $height ($in.index * $width) 0 }
  | reduce { |it, acc| $acc | merge $it }
}

def constructDeck [ cards: table, deckName: string, width: int, height: int, x: int, y: int ] {
  let cardTypes = $cards
  | reject path vttFileName
  | group-by index --prune 
  | items { |cardId,cardData| { 
    name: $"($deckName)($cardId)",
    sides: ($cardData | transpose -rd) } 
  } | transpose -rd

  {
    $"($deckName)Holder": {
      id: $"($deckName)Holder",
      type: "holder",
      x: $x,
      y: $y,
      width: $width,
      height: $height
    },
    $"($deckName)Pile": {
      id: $"($deckName)Pile",
      type: "pile",
      parent: $"($deckName)Holder"
      width: $width,
      height: $height
    },
    $"($deckName)Deck": {
      id: $"($deckName)Deck",
      type: "deck",
      parent: $"($deckName)Holder"
      cardDefaults: {
        width: $width,
        height: $height,
        color: "transparent",
        enlarge: 3,
        clickRoutine: [
          {
            func: "FLIP",
            collection: "thisButton"
          }
        ],
        doubleClickRoutine: [
          {
            func: "ROTATE",
            collection: "thisButton"
          }
        ],
      },
      cardTypes: $cardTypes,
      faceTemplates: [
        {
          objects: [
            { 
              type: "image", 
              width: $width,
              height: $height,
              dynamicProperties: {
                value: "back"
              }
            }
          ] 
        }
        { 
          objects: [
            { 
              type: "image", 
              width: $width,
              height: $height,
              dynamicProperties: {
                value: "front"
              }
            }
          ] 
        }
      ],
    },
  }
}

# Package card images as a .vtt zip file compatible with virtualtabletop.io.
# Each has to be represented by an image file.
# Each image file has to be named according to the following scheme:
# $"($anyPrefix)-($deckName)-($side)($cardNumber)($anySuffixAndExtension)"
# Explanation:
# - anyPrefix/anySuffixAndExtension -> any string without '-'
# - deckName -> name of the deck to which the card belongs to, each unique deck name will result in a separate vtt deck
# - side -> 'front' or 'back'
# - cardNumber -> number-only unique id of the card
export def packageCardImagesAsVttGame [ 
  imagesDir: path # directory of card images
  outDir: path # output directory
  gameName: string = "Generated Card Game" # game name displayed in virtualtabletop.io
  cardWidth: int = 125
  cardHeight: int = 175
  # TODO: implement the below
  # extraDataCardDefaults: path = "" # a path to a nu-openable file containing data that will be merged with cardDefaults section of each generated deck
  # extraDataTopLevel: path = "" # a path to a nu-openable file containing data that will be merged with the final generated data
] {
  let assetsDir = "staging/assets"
  mkdir $assetsDir

  # TODO: move conversion to webp to web output variant instead
  ls $imagesDir | get name | each {
    ^cwebp $in -o $"($assetsDir)/($in | path basename).webp"
  }

  let cardImageAssetData = createImageAssetData $assetsDir

  $cardImageAssetData | each { mv -f $in.path $"($assetsDir)/($in.vttFileName)" } 

  let cardInstanceStructs = createCardInstanceVttStructs $cardImageAssetData

  let $baseStruct = {
    _meta: { 
      version: 21, 
      info: { 
        name: $gameName, 
      } 
    }
    hand: {
      type: "holder",
      id: "hand",
      x: 0,
      y: (1000 - $cardHeight),
      height: $cardHeight,
      width: 800, # half a room
      childrenPerOwner: true,
      hidePlayerCursors: true,
      onEnter: {
        activeFace: 1
      },
      onLeave: {
        activeFace: 0
      },
      stackOffsetX: ($cardWidth / 2)
    }
  }

  let deckStructs = createDeckVttStructs $cardImageAssetData $cardWidth $cardHeight

  $baseStruct 
  | merge $deckStructs
  | merge $cardInstanceStructs
  | to json
  | save -f staging/0.json

  mkdir $outDir
  cd staging
  ^zip -9rq $"($outDir)/($gameName).vtt" .

  cd ..
  rm -rf staging
}
