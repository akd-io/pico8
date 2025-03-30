# AKD's PICO-8 and Picotron projects

## Picotron

### Setup

This repo stores a picotron drive at `picotron/drive`. To use this as your Picotron drive, and commit changes to the repo, update your `picotron_config.txt` to point to this repo's `picotron/drive` folder.

On my machine, `picotron_config.txt` was located at `/Users/akd/Library/Application Support/Picotron/picotron_config.txt`, and I updated it to:

```
# picotron config

mount / /Users/akd/workspace/pico/picotron/drive
```

### Accessing root folder in host OS

Because we have remapped the drive folder mount, we don't have easy access to the root Picotron folder (parent of the `drive` folder) when running the `folder` command in Picotron.

The root folder can be accessed using:

- `open "/Users/akd/Library/Application Support/Picotron"`
