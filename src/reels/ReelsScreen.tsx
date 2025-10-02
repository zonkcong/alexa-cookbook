import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { motion, PanInfo, useVelocity, useMotionValue } from 'framer-motion';
import { Reel } from './types';
import { ReelItem } from './ReelItem';

const sampleReels: Reel[] = [
  { id: '1', src: '/videos/reel1.mp4', username: 'alice', caption: 'Sunset vibes 🌅', audio: 'Original Audio' },
  { id: '2', src: '/videos/reel2.mp4', username: 'bob', caption: 'City timelapse 🏙️', audio: 'City Beat' },
  { id: '3', src: '/videos/reel3.mp4', username: 'chris', caption: 'Surfing the waves 🏄', audio: 'Ocean Mix' },
  { id: '4', src: '/videos/reel4.mp4', username: 'dana', caption: 'Mountain hike ⛰️', audio: 'Wind Chimes' },
  { id: '5', src: '/videos/reel5.mp4', username: 'eric', caption: 'Street food tour 🍜', audio: 'Street Beats' },
];

const SPRING = { type: 'spring', stiffness: 260, damping: 28, mass: 0.9 } as const;

export function ReelsScreen() {
  const [index, setIndex] = useState(0);
  const containerRef = useRef<HTMLDivElement | null>(null);

  // y offset for the feed
  const y = useMotionValue(0);
  const velocity = useVelocity(y);

  const height = () => containerRef.current?.clientHeight ?? 0;

  const clampIndex = useCallback((i: number) => Math.max(0, Math.min(sampleReels.length - 1, i)), []);

  const snapToIndex = useCallback(
    (i: number) => {
      const next = clampIndex(i);
      setIndex(next);
      const h = height();
      const targetY = -next * h;
      y.stop();
      y.set(targetY);
    },
    [clampIndex, y]
  );

  const handleDragEnd = useCallback(
    (_: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
      const h = height();
      const threshold = h * 0.18;
      const vy = velocity.get();
      let next = index;

      if (info.offset.y < -threshold || vy < -800) next = index + 1; // swipe up → next
      if (info.offset.y > threshold || vy > 800) next = index - 1; // swipe down → prev

      // rubber-band bounce when hitting ends
      if (next < 0 || next >= sampleReels.length) {
        next = clampIndex(next);
      }

      snapToIndex(next);
    },
    [clampIndex, index, snapToIndex, velocity]
  );

  const onDoubleLike = useCallback((_id: string) => {
    // Could trigger haptic-like feedback using subtle UI bump
  }, []);

  // Preload nearby videos
  const preloads = useMemo(() => {
    const around = [index - 1, index + 1].filter((i) => i >= 0 && i < sampleReels.length);
    return around.map((i) => sampleReels[i].src);
  }, [index]);

  // Adjust on resize to keep snap position correct
  useEffect(() => {
    const onResize = () => {
      const h = height();
      y.set(-index * h);
    };
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, [index, y]);

  return (
    <div ref={containerRef} className="relative h-screen w-screen overflow-hidden bg-black">
      {preloads.map((src) => (
        <link key={src} rel="preload" as="video" href={src} />
      ))}

      <motion.div
        className="absolute inset-0"
        style={{ y }}
        drag="y"
        dragConstraints={{ top: 0, bottom: 0 }}
        dragElastic={0.25}
        onDragEnd={handleDragEnd}
        transition={SPRING}
      >
        {sampleReels.map((reel, i) => (
          <div key={reel.id} className="h-screen w-screen">
            <ReelItem reel={reel} isActive={i === index} onDoubleLike={onDoubleLike} />
          </div>
        ))}
      </motion.div>
    </div>
  );
}
