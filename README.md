![Illustration of a square bookshelf stocked with several books](icons/icon_256.png)

# Bookoscope

#### BOOKOSCOPE IS:

A unified, searchable, visual, book-first catalog for all your OPDS endpoints.

#### WHAT IS OPDS?

[OPDS](https://opds.io/) is the open standard for web endpoints that expose catalogs of ebooks, comics, and/or manga. Many people use home OPDS servers for their personal ebook libraries.

#### WHY?

Some ereader apps can connect to OPDS endpoints, but the functionality is tucked away and awkward. There's no way to browse and search all the ebooks you have access to, all at once.

Bookoscope fills that very small, very important niche. It crawls your OPDS endpoints, finds and caches all the books it can, and lets you easily download any of them to your device. From there, you can import them to your preferred ereader.

#### SELLING POINTS:

- Fast
- Easy on the eyes
- Includes over 70,000 public domain books from Project Gutenberg
- Uses cached feeds (refresh on demand)
- Searchable by any available metadata
- Quick download and export to the ereader of your choice

#### BOOKOSCOPE IS *NOT:*

- An ebook reader, sync client, or annotator, like Apple Books, Google Books, or Kindle.
- A metadata editor or organizer, like Calibre.
- A self-hosted ebook server, like Kavita, Ubooquity, or calibre-web.
- A pirating tool.

You can use Bookoscope to enhance an e-reading experience that includes any or all of the above. However, Bookoscope does not endorse or affiliate with any other app or tool.

# Get the app

<!-- Visit [isaaclyman.com/bookoscope](https://isaaclyman.com/bookoscope/) for links to download on the App Store and Google Play. -->

Not yet published.

# Support

If there's a problem with the app, you may [file an issue](https://github.com/isaaclyman/bookoscope/issues).

If the app doesn't correctly crawl an OPDS endpoint, **please provide at least one of the following:**

- A direct link to the endpoint and a username and password (if required).
- The complete XML download of all of the following:
  - The root OPDS feed
  - Any other feeds referenced by the root
  - At least one feed that includes an individual book \<entry> element

If you'd like me to spend more time on this app (meaning more free features for everyone), simply [sponsor me](https://ko-fi.com/isaaclyman).

# Roadmap

- If the OPDS 2.0 draft becomes stable at some point, supporting that will become a priority. For now, only OPDS 1.x is supported.
- Help needed to test with a variety of different OPDS servers.

# Contributing

Before submitting a PR, please file an issue describing the feature or fix you'd like to work on. This will help me coordinate with any ongoing work.

# Development

When anything in `lib/db/` changes:

`dart run build_runner build`