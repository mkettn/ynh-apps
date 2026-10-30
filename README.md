# Mark's application catalog

This repository contains my YunoHost app catalog, based on the
[default YunoHost app catalog](https://github.com/YunoHost/apps).

Most of it is AI generated and packaged, and tested by me

## Content of this repository

### `apps.toml`

This is the main catalog file, containing references to the apps' repositories,
along with a few metadata about them such as their category or maintenance state.

It is regularly read by the [catalog builder](https://github.com/YunoHost/apps-tools)
which publishes the results on <https://app.yunohost.org/default>.

### `categories.toml` and `antifeatures.toml`

Those files contain infos about apps metadatas.

### `graveyard.toml`

This file is for apps that are long-term not-working and unlikely to be ever revived.

### `wishlist.toml`

This file contains apps that users wish to be packaged. If you want to help YunoHost, check it out!

It is [browsable online](https://apps.yunohost.org/wishlist).

### `rejectedlist.toml`

This file contains apps that will not be packaged, because of incompatibilities with the YunoHost project.
It is used to prevent apps to be added to the wishlist.
