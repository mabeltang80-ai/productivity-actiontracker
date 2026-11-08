# Meeting Action Tracker

A single-page tracker for actions agreed in meetings. Add an action with an owner and due date, tick it off when done, and see open, done and overdue counts at a glance. Overdue actions are highlighted in red.

- Plain HTML, CSS and JavaScript in one file (`index.html`). No build step, no dependencies.
- Data is saved in the browser's local storage, so each person sees their own list.

## Deploy to Vercel

1. Sign in at [vercel.com](https://vercel.com) and choose **Add New... > Project**.
2. Import this GitHub repository.
3. Set **Framework Preset** to **Other**. Leave Build Command and Output Directory empty.
4. Click **Deploy**.

`vercel.json` turns on clean URLs and adds basic security headers.

## Run locally

Open `index.html` in a browser.
