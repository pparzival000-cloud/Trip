# Europe Travel Guide

This repository contains the static website shell for the editable trip guide. The website now shows an invitation screen unless it is opened with a valid trip link. The itinerary and accommodation details are stored in Supabase, not in this repository.

## Link-based access

- The ordinary GitHub Pages address displays an access screen.
- A complete trip link loads the matching Supabase record and allows editing.
- Anyone who receives that complete link can view and edit the trip. There are no individual accounts or per-person permissions, so share the link only with trusted people.
- The GitHub repository and static site are still publicly reachable. This setup protects the trip data with an unguessable link; it is not account-authenticated private hosting.
- To revoke a trip link, delete its matching row from `public.shared_trip_guides` in the Supabase SQL Editor. Use the share key from the link. Revoking one link does not revoke other links.

## Supabase setup

Run `supabase_setup.sql` once in the Supabase project's SQL Editor. The setup creates the shared-guide table and the read/write functions used by the browser. The direct table access is revoked; browser access uses the random 192-bit share key.

The frontend uses a public publishable key (or legacy anon key). Never put a Supabase secret or service-role key in this repository or webpage.

## Sync behavior

The site saves the complete guide as one document and checks for remote updates every few seconds. If two devices edit different fields at exactly the same time, the later full-document save may overwrite the earlier one. Back up the guide periodically.

GitHub Pages publishing instructions: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site



## Private handwritten map

The handwritten atlas photo and expedition card are stored in the separate `shared_trip_guide_assets` table in Supabase. The page requests them through `get_shared_guide_map` only after the invitation key has opened a valid trip. Direct table access is revoked, and the image data is not committed to this repository. Add this table and RPC with the SQL at the end of `supabase_setup.sql` when setting up another Supabase project.
