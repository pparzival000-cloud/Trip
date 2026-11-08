# Europe Travel Guide — shared website

This folder is a static website shell for the editable guide. It does not embed the detailed itinerary, accommodation addresses, or booking data. The itinerary is stored in your Supabase project and loaded only by a shared link.

## Reference project

The collaboration pattern was informed by [Cairn](https://github.com/thkleinert/cairn), an MIT-licensed, self-hostable collaborative trip planner using Supabase for shared trip changes. This guide is a separate, original single-page app.

## Set up shared sync

1. Create a Supabase project. In its SQL Editor, run `supabase_setup.sql`. The setup creates a table and two narrowly scoped database functions; direct access to the table is revoked.
2. Publish this folder as a static website. For GitHub Pages, put the contents of this folder at the publishing root (including `index.html`). GitHub Pages serves static HTML, CSS and JavaScript. Its sites are public, so do not publish the original full itinerary file. This folder's `index.html` is a data-free shell.
3. Open the existing full guide on your computer and choose **Back up guide** to save its JSON backup.
4. Open the hosted website and choose **Import backup** to load your itinerary into that browser.
5. In **Share & sync**, enter your Supabase Project URL, the public publishable key (or legacy anon key), and the hosted website URL. Choose **Create shared link**. The guide uploads to Supabase and creates a link you can open on other devices.
6. Share that link with the people who should be able to edit. Their changes are checked and synchronized automatically every few seconds. Updates also save in each browser.

## Privacy and access

The website shell is public. Your trip data is not embedded in it; it is fetched from the database using a random 192-bit share key in the link fragment. Anyone who has the complete link can view and edit the trip, so treat it like a password and share it only with trusted people. The public Supabase key is designed for browser use; never paste a service-role or secret key into the page.

To revoke an old link, delete its row from `public.shared_trip_guides` in the Supabase SQL Editor using the link share key. Creating a new link alone does not disable the old one.

## Sync behavior

This lightweight version saves the whole guide as one document and checks for remote updates every three seconds. If two devices edit different fields at exactly the same time, the most recent full-document save can replace the earlier one. Avoid simultaneous edits to reduce that risk. Back up the guide periodically.

GitHub Pages publishing instructions: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site

