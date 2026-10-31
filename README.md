# Mark's application catalog

This repository contains my YunoHost app catalog, based on the
[default YunoHost app catalog](https://github.com/YunoHost/apps).

Most of it is AI generated and packaged, and tested by me

## Content of this repository

### `apps.toml`

This is the main catalog file, containing references to the apps' repositories,
along with a few metadata about them such as their category or maintenance state.

It is read by the [catalog builder](https://github.com/YunoHost/apps-tools)
to generate this catalog. It is not published to the official YunoHost catalog.

### `categories.toml` and `antifeatures.toml`

Those files contain infos about apps metadatas.

### `graveyard.toml`

This file is for apps that are long-term not-working and unlikely to be ever revived.

### `wishlist.toml`

This file contains apps that I'd like to package.

### `rejectedlist.toml`

This file contains apps that will not be packaged in this catalog.
It is used to prevent apps to be added to the wishlist.

## Publishing the catalog

`publish_catalog.sh` builds the catalog with YunoHost's
[apps-tools](https://github.com/YunoHost/apps-tools), through `build_catalog.py`.
Unlike apps-tools' own `list_builder.py`, it doesn't push the app list to the
YunoHost forum, report errors to YunoHost's Matrix rooms, or pull results from
YunoHost's dev CI:

```bash
./publish_catalog.sh                     # writes builds/default/
./publish_catalog.sh /some/served/dir    # writes somewhere else
PUBLISH_DEST=user@host:/var/www/catalog ./publish_catalog.sh   # also rsyncs it there
```

Serve the output directory over HTTPS (for example with a My Webapp), so that
`<catalog url>/v3/apps.json` is reachable. Then on each YunoHost server, add the
catalog to `/etc/yunohost/apps_catalog.yml`, next to the default one:

```yaml
- id: default
  url: https://app.yunohost.org/default
- id: mkettn
  url: https://<your host>/catalog
```

and run `yunohost tools update apps`.
