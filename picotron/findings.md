# Picotron findings

## mkdir()

Current behavior:

- On success, mkdir() returns nil.
- On failure, mkdir() returns "mkdir failed".

Expected behavior:

On failure, mkdir() throws an error?

Or mkdir() returns `success, error`, where `success` is a boolean and `error` is an error message.

I've only tried mkdir() failing when trying to create a directory in a directory that doesn't exist. A specific error message for that scenario would be great.

A possible fix could also be to make mkdir() recursive by default.
