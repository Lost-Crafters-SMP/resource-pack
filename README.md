# Lost Crafters Resource Pack
This repo contains the custom resource pack used on the Lost Crafters SMP.

## Getting Started
To add your own custom resources, first claim your ID on the google spread sheet. The link to this spreadsheet can be found in the `#faq` channel on discord

If you want to add your own images to the resource pack, you can use the guide below, if you need help ask in the `#custom-resource-pack-chat`

Note: If you are going to submit a pull request, your github username must be added to the spread sheet or it will be denied. Only members of Lost Crafters are allowed to submit changes to the resource pack.

## Naming scheme
the json and images uploaded to the resource pack must follow this naming scheme

`{id}-{item_name}.{file ext}`

There must be a `-` between the id and the item name, and spaces must be converted to `_` underscores. This is to make it easy to find and identify assets.

## Basics
Under the `assets` folder in the `minecraft` folder is all the items in the game and their resources. To add an override, first find the item you wish to override, for this example we will use `minecraft:golden_carrot`. The json for this item can be found in `assets/minecraft/models/item/golden_carrot.json`

By default you will see the default json if there are no overrides. The default json will look like
```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "minecraft:item/golden_carrot"
  }
}
```

The override json will get added after the texture
```json
"overrides": [
  {
    "predicate": { "custom_model_data": id},
    "model": "custom:item/custom_model"
  }
]
```

So the overall file should now look like
```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "minecraft:item/golden_carrot"
  },
  "overrides": [
    {	
      "predicate": {"custom_model_data": id},
      "model": "custom:item/custom_model"
    }
  ]
}
```

All the custom models will live in the `custom` folder