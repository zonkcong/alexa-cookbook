# Facebook Reels Prototype (iOS-style)

A modern, fluid Facebook Reels interactive prototype built with React (TypeScript), Tailwind CSS, and Framer Motion. Designed to feel like a production-ready iOS experience.

## Quick Start

```bash
npm install
npm run dev
```

Open the app at the printed URL (usually `http://localhost:5173`).

## Add Your Videos

Place 5+ `.mp4` files in `public/videos` with these names:

- `/videos/reel1.mp4`
- `/videos/reel2.mp4`
- `/videos/reel3.mp4`
- `/videos/reel4.mp4`
- `/videos/reel5.mp4`

You can add more and update the `sampleReels` array in `src/reels/ReelsScreen.tsx`.

## Features

- Full-screen, swipeable vertical video feed
- Auto-play when in view, seamless looping
- Tap to pause/play
- Double-tap to like with heart animation
- Vertical swipe navigation with rubber-band effect and springy animations
- iOS-style UI: top bar, right sidebar actions, glassmorphic overlays
- Dark gradient readability overlays, rounded UI, blur effects
- Preloads next/prev video for smoother playback

## Tech Stack

- React + TypeScript
- Tailwind CSS
- Framer Motion
- Vite

## Notes

- For iOS Safari autoplay: videos are muted by default and use `playsinline`.
- Adjust spring tuning in `src/reels/ReelsScreen.tsx` for feel.
